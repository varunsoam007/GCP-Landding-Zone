# Create a Network Firewall Policy
resource "google_compute_network_firewall_policy" "enterprise_policy" {
  name        = "enterprise-firewall-policy"
  description = "Global network firewall policy for enterprise hub VPC"
  project     = google_compute_shared_vpc_host_project.host.project
}

# Associate the Firewall Policy with the Hub VPC
resource "google_compute_network_firewall_policy_association" "enterprise_policy_assoc" {
  name              = "enterprise-policy-association"
  attachment_target = google_compute_network.hub_vpc.id
  firewall_policy   = google_compute_network_firewall_policy.enterprise_policy.id
  project           = google_compute_shared_vpc_host_project.host.project
}

# Rule to allow internal VPC traffic (Nodes, GKE Pods, GKE Services)
resource "google_compute_network_firewall_policy_rule" "allow_internal" {
  action          = "allow"
  description     = "Allow internal traffic within the VPC including GKE nodes, pods, and services"
  direction       = "INGRESS"
  disabled        = false
  firewall_policy = google_compute_network_firewall_policy.enterprise_policy.name
  priority        = 1000
  project         = google_compute_shared_vpc_host_project.host.project
  rule_name       = "allow-internal"
  match {
    src_ip_ranges = [
      "10.10.0.0/20", # GKE Nodes (private-subnet-01)
      "10.11.0.0/16", # GKE Pods (gke-pod-range)
      "10.12.0.0/20"  # GKE Services (gke-svc-range)
    ]
    layer4_configs {
      ip_protocol = "all"
    }
  }
}

# Rule to allow IAP (Identity-Aware Proxy) for SSH/RDP access
resource "google_compute_network_firewall_policy_rule" "allow_iap" {
  action          = "allow"
  description     = "Allow IAP for SSH and RDP"
  direction       = "INGRESS"
  disabled        = false
  firewall_policy = google_compute_network_firewall_policy.enterprise_policy.name
  priority        = 1001
  project         = google_compute_shared_vpc_host_project.host.project
  rule_name       = "allow-iap"
  match {
    src_ip_ranges = ["35.235.240.0/20"]
    layer4_configs {
      ip_protocol = "tcp"
      ports       = ["22", "3389"]
    }
  }
}

# Rule to allow Google Cloud External L7 Load Balancer and Health Checks to GKE
resource "google_compute_network_firewall_policy_rule" "allow_l7_lb_and_health_checks" {
  action          = "allow"
  description     = "Allow Google Cloud Global External L7 Application Load Balancer and health checks to reach GKE backends"
  direction       = "INGRESS"
  disabled        = false
  firewall_policy = google_compute_network_firewall_policy.enterprise_policy.name
  priority        = 1002
  project         = google_compute_shared_vpc_host_project.host.project
  rule_name       = "allow-l7-lb-and-health-checks"
  match {
    src_ip_ranges = [
      "130.211.0.0/22", # Google Cloud External L7 LB & Health Checks
      "35.191.0.0/16"   # Google Cloud External L7 LB & Health Checks
    ]
    layer4_configs {
      ip_protocol = "tcp"
      ports       = ["80", "443", "8080", "15021", "30000-32767"]
    }
  }
}

# Rule to allow Envoy Proxy-Only Subnet (Regional L7 Load Balancer) to GKE
resource "google_compute_network_firewall_policy_rule" "allow_proxy_subnet" {
  action          = "allow"
  description     = "Allow Envoy Regional Managed Proxy subnet to reach GKE backends"
  direction       = "INGRESS"
  disabled        = false
  firewall_policy = google_compute_network_firewall_policy.enterprise_policy.name
  priority        = 1003
  project         = google_compute_shared_vpc_host_project.host.project
  rule_name       = "allow-proxy-subnet"
  match {
    src_ip_ranges = ["10.13.0.0/24"] # Proxy-only subnet from loadbalancer.tf
    layer4_configs {
      ip_protocol = "tcp"
      ports       = ["80", "443", "8080", "15021", "30000-32767"]
    }
  }
}

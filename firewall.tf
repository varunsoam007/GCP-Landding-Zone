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

# Rule to allow internal VPC traffic
resource "google_compute_network_firewall_policy_rule" "allow_internal" {
  action          = "allow"
  description     = "Allow internal traffic within the VPC"
  direction       = "INGRESS"
  disabled        = false
  firewall_policy = google_compute_network_firewall_policy.enterprise_policy.name
  priority        = 1000
  project         = google_compute_shared_vpc_host_project.host.project
  rule_name       = "allow-internal"
  match {
    src_ip_ranges = ["10.10.0.0/20"]
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

# 1. Create a Threat Prevention Security Profile (Cloud NGFW Enterprise)
resource "google_network_security_security_profile" "threat_prevention" {
  name        = "enterprise-threat-prevention"
  type        = "THREAT_PREVENTION"
  parent      = "organizations/${var.org_id}" # NGFW Profiles are usually org or folder level
  description = "Block severe threats using Cloud NGFW Enterprise"

  depends_on = [google_project_service.network_security_api]
}

# 2. Create a Security Profile Group
resource "google_network_security_security_profile_group" "ngfw_profile_group" {
  name                      = "enterprise-profile-group"
  parent                    = "organizations/${var.org_id}"
  description               = "Group containing Threat Prevention profile"
  threat_prevention_profile = google_network_security_security_profile.threat_prevention.id
}

# 3. Create Firewall Endpoint (NGFW Inspection Engine in a specific zone)
resource "google_network_security_firewall_endpoint" "ngfw_endpoint" {
  name               = "enterprise-ngfw-endpoint"
  parent             = "organizations/${var.org_id}"
  location           = "${var.region}-a"
  billing_project_id = var.host_project_id

  depends_on = [google_project_service.network_security_api]
}

# 4. Associate the Firewall Endpoint with the Hub VPC
resource "google_network_security_firewall_endpoint_association" "vpc_association" {
  name              = "hub-vpc-ngfw-association"
  parent            = "projects/${var.host_project_id}/locations/${var.region}-a"
  location          = "${var.region}-a"
  network           = google_compute_network.hub_vpc.id
  firewall_endpoint = google_network_security_firewall_endpoint.ngfw_endpoint.id
}

# 5. Add a Firewall Policy Rule to route traffic to NGFW for Inspection
resource "google_compute_network_firewall_policy_rule" "ngfw_inspection_rule" {
  action          = "apply_security_profile_group"
  description     = "Inspect all outgoing internet traffic with Cloud NGFW Enterprise"
  direction       = "EGRESS"
  disabled        = false
  firewall_policy = google_compute_network_firewall_policy.enterprise_policy.name
  priority        = 500 # Higher priority than basic allow rules
  project         = google_compute_shared_vpc_host_project.host.project
  rule_name       = "inspect-outbound-traffic"

  security_profile_group = google_network_security_security_profile_group.ngfw_profile_group.id

  match {
    dest_ip_ranges = ["0.0.0.0/0"]
    layer4_configs {
      ip_protocol = "tcp"
    }
  }

  # Ensure the endpoint is associated before traffic is routed
  depends_on = [
    google_network_security_firewall_endpoint_association.vpc_association
  ]
}

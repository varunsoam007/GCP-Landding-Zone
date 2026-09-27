# ==============================================================================
# Load Balancer Infrastructure Prerequisites
# ==============================================================================

# 1. Reserve a Static Public IP for the domain (jksoa.in)
# This IP will be attached to the Load Balancer by GKE's Ingress Controller.
resource "google_compute_global_address" "jksoa_ingress_ip" {
  name    = "jksoa-ingress-ip"
  project = google_compute_shared_vpc_host_project.host.project
  description = "Static IP for jksoa.in Ingress"
}

# 2. Proxy-Only Subnet
# Required for modern Envoy-based Regional/Internal Application Load Balancers in GCP.
# (GCP's equivalent of Azure Application Gateway often uses Envoy under the hood).
resource "google_compute_subnetwork" "proxy_subnet" {
  name          = "proxy-only-subnet"
  project       = google_compute_shared_vpc_host_project.host.project
  region        = var.region
  network       = google_compute_network.hub_vpc.id
  ip_cidr_range = "10.13.0.0/24" # A small /24 is enough for proxy subnets
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

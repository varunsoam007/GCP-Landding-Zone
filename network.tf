# 1. Enable Shared VPC in the Host Project
resource "google_compute_shared_vpc_host_project" "host" {
  project    = var.host_project_id
  depends_on = [google_project_service.compute_api]
}

# 3. Create the Hub VPC Network (in Host Project)
resource "google_compute_network" "hub_vpc" {
  name                    = "enterprise-hub-vpc"
  project                 = google_compute_shared_vpc_host_project.host.project
  auto_create_subnetworks = false
  routing_mode            = "GLOBAL"
}

# 4. Create a general Private Subnet (in Host Project)
resource "google_compute_subnetwork" "private_subnet" {
  name                     = "private-subnet-01"
  project                  = google_compute_shared_vpc_host_project.host.project
  region                   = var.region
  network                  = google_compute_network.hub_vpc.id
  ip_cidr_range            = "10.10.0.0/20"
  private_ip_google_access = true

  # Secondary IP ranges are REQUIRED for VPC-native GKE clusters
  # One range for Pod IPs, one for Service IPs.
  secondary_ip_range {
    range_name    = "gke-pod-range"
    ip_cidr_range = "10.11.0.0/16"
  }
  secondary_ip_range {
    range_name    = "gke-svc-range"
    ip_cidr_range = "10.12.0.0/20"
  }
}

# 5. Cloud NAT (So private VMs can reach internet for updates)
resource "google_compute_router" "hub_router" {
  name    = "hub-router"
  project = google_compute_shared_vpc_host_project.host.project
  region  = var.region
  network = google_compute_network.hub_vpc.id
}

resource "google_compute_router_nat" "hub_nat" {
  name                               = "hub-nat"
  project                            = google_compute_shared_vpc_host_project.host.project
  region                             = var.region
  router                             = google_compute_router.hub_router.name
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
  nat_ip_allocate_option             = "AUTO_ONLY"
}

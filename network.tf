# 1. Enable Shared VPC in the Host Project
resource "google_compute_shared_vpc_host_project" "host" {
  project = var.host_project_id
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

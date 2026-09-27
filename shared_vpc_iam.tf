# ==============================================================================
# Shared VPC Attachment & IAM Configuration for GKE
# ==============================================================================

# Data block to get the service project number (required for default service account emails)
data "google_project" "service_project" {
  project_id = var.project_id
}

# Attach the Service Project to the Host Project Shared VPC
resource "google_compute_shared_vpc_service_project" "gke_service_project" {
  host_project    = google_compute_shared_vpc_host_project.host.project
  service_project = var.project_id
  depends_on = [google_compute_shared_vpc_host_project.host]
}

# ------------------------------------------------------------------------------
# IAM Roles for GKE in Shared VPC
# GKE service accounts in the Service Project need permissions in the Host Project
# to use the subnetwork and create firewall rules.
# ------------------------------------------------------------------------------

# 1. Grant Network User role on the private subnetwork to the Service Project's GKE robot
resource "google_compute_subnetwork_iam_member" "gke_robot_network_user" {
  subnetwork = google_compute_subnetwork.private_subnet.name
  project    = google_compute_shared_vpc_host_project.host.project
  region     = var.region
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:service-${data.google_project.service_project.number}@container-engine-robot.iam.gserviceaccount.com"
}

# 2. Grant Network User role on the private subnetwork to the Service Project's Google APIs SA
resource "google_compute_subnetwork_iam_member" "apis_sa_network_user" {
  subnetwork = google_compute_subnetwork.private_subnet.name
  project    = google_compute_shared_vpc_host_project.host.project
  region     = var.region
  role       = "roles/compute.networkUser"
  member     = "serviceAccount:${data.google_project.service_project.number}@cloudservices.gserviceaccount.com"
}

# 3. Grant Host Service Agent User role on the Host Project to the Service Project's GKE robot
resource "google_project_iam_member" "gke_host_agent" {
  project = google_compute_shared_vpc_host_project.host.project
  role    = "roles/container.hostServiceAgentUser"
  member  = "serviceAccount:service-${data.google_project.service_project.number}@container-engine-robot.iam.gserviceaccount.com"
}

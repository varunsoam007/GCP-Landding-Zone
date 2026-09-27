resource "google_project_service" "compute_api" {
  project            = var.host_project_id
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "network_security_api" {
  project            = var.project_id
  service            = "networksecurity.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "network_security_api_host" {
  project            = var.host_project_id
  service            = "networksecurity.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "container_api" {
  project            = var.host_project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "container_api_service" {
  project            = var.project_id
  service            = "container.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "dns_api" {
  project            = var.host_project_id
  service            = "dns.googleapis.com"
  disable_on_destroy = false
}


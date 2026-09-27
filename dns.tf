# ==============================================================================
# Cloud DNS Configuration
# ==============================================================================

# 1. Create a Public Managed Zone for the domain
resource "google_dns_managed_zone" "jksoam_zone" {
  name        = "jksoam-in-zone"
  dns_name    = "jksoam.in." # Note the trailing dot, it's required for DNS
  description = "Public DNS zone for jksoam.in"
  project     = google_compute_shared_vpc_host_project.host.project

  visibility = "public"

  depends_on = [
    google_project_service.dns_api
  ]
}

# 2. Create an A Record pointing the domain to our static Ingress IP
resource "google_dns_record_set" "root_a_record" {
  name         = google_dns_managed_zone.jksoam_zone.dns_name
  managed_zone = google_dns_managed_zone.jksoam_zone.name
  project      = google_compute_shared_vpc_host_project.host.project
  type         = "A"
  ttl          = 300

  # Pointing to the static IP we created in loadbalancer.tf
  rrdatas = [google_compute_global_address.jksoa_ingress_ip.address]
}

# 3. Wildcard A Record (Optional but useful for subdomains like api.jksoam.in)
resource "google_dns_record_set" "wildcard_a_record" {
  name         = "*.${google_dns_managed_zone.jksoam_zone.dns_name}"
  managed_zone = google_dns_managed_zone.jksoam_zone.name
  project      = google_compute_shared_vpc_host_project.host.project
  type         = "A"
  ttl          = 300

  rrdatas = [google_compute_global_address.jksoa_ingress_ip.address]
}

# 4. Explicit A Record for shop.jksoam.in
resource "google_dns_record_set" "shop_a_record" {
  name         = "shop.${google_dns_managed_zone.jksoam_zone.dns_name}"
  managed_zone = google_dns_managed_zone.jksoam_zone.name
  project      = google_compute_shared_vpc_host_project.host.project
  type         = "A"
  ttl          = 300

  rrdatas = [google_compute_global_address.jksoa_ingress_ip.address]
}

# ==============================================================================
# Cert Manager & External DNS - GCP Workload Identity
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Cert Manager Service Account
# ------------------------------------------------------------------------------
resource "google_service_account" "cert_manager_sa" {
  account_id   = "cert-manager"
  display_name = "Cert Manager Service Account"
  project      = var.project_id
}

# Grant DNS Admin role to Cert Manager SA on the HOST project (where DNS zone lives)
resource "google_project_iam_member" "cert_manager_dns_admin" {
  project = var.shared_vpc_host_project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.cert_manager_sa.email}"
}

# Workload Identity binding for Cert Manager
resource "google_service_account_iam_binding" "cert_manager_workload_identity" {
  service_account_id = google_service_account.cert_manager_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[cert-manager/cert-manager]"
  ]
}

# ------------------------------------------------------------------------------
# 2. External DNS Service Account
# ------------------------------------------------------------------------------
resource "google_service_account" "external_dns_sa" {
  account_id   = "external-dns"
  display_name = "External DNS Service Account"
  project      = var.project_id
}

# Grant DNS Admin role to External DNS SA on the HOST project
resource "google_project_iam_member" "external_dns_dns_admin" {
  project = var.shared_vpc_host_project_id
  role    = "roles/dns.admin"
  member  = "serviceAccount:${google_service_account.external_dns_sa.email}"
}

# Workload Identity binding for External DNS
resource "google_service_account_iam_binding" "external_dns_workload_identity" {
  service_account_id = google_service_account.external_dns_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[external-dns/external-dns]"
  ]
}

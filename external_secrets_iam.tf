# ==============================================================================
# External Secrets Operator (ESO) - GCP Workload Identity
# ==============================================================================

# 1. Create a dedicated GCP Service Account for External Secrets
resource "google_service_account" "external_secrets_sa" {
  account_id   = "external-secrets"
  display_name = "External Secrets Operator Service Account"
  project      = var.project_id
}

# 2. Grant Secret Manager Secret Accessor role so it can read secrets
# This is granted at the project level, meaning it can read ALL secrets in the Service Project.
resource "google_project_iam_member" "external_secrets_secret_accessor" {
  project = var.project_id
  role    = "roles/secretmanager.secretAccessor"
  member  = "serviceAccount:${google_service_account.external_secrets_sa.email}"
}

# 3. Allow Kubernetes Service Account to impersonate the GCP Service Account (Workload Identity)
# The GKE cluster automatically configures a Workload Identity Pool for the project.
resource "google_service_account_iam_binding" "external_secrets_workload_identity" {
  service_account_id = google_service_account.external_secrets_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    # Format: serviceAccount:PROJECT_ID.svc.id.goog[K8S_NAMESPACE/K8S_SERVICE_ACCOUNT]
    "serviceAccount:${var.project_id}.svc.id.goog[external-secrets/external-secrets-sa]"
  ]
}

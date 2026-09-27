# ==============================================================================
# Observability (Loki, Mimir, Tempo) - GCP Workload Identity & Storage
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Loki Storage & IAM
# ------------------------------------------------------------------------------
resource "google_storage_bucket" "loki_storage" {
  name          = "${var.project_id}-loki-storage"
  location      = var.region
  force_destroy = true
  project       = var.project_id
  uniform_bucket_level_access = true
}

resource "google_service_account" "loki_sa" {
  account_id   = "loki-sa"
  display_name = "Loki Service Account"
  project      = var.project_id
}

resource "google_storage_bucket_iam_member" "loki_storage_admin" {
  bucket = google_storage_bucket.loki_storage.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.loki_sa.email}"
}

resource "google_service_account_iam_binding" "loki_workload_identity" {
  service_account_id = google_service_account.loki_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[loki/loki]"
  ]
}

# ------------------------------------------------------------------------------
# 2. Mimir Storage & IAM
# ------------------------------------------------------------------------------
resource "google_storage_bucket" "mimir_storage" {
  name          = "${var.project_id}-mimir-storage"
  location      = var.region
  force_destroy = true
  project       = var.project_id
  uniform_bucket_level_access = true
}

resource "google_service_account" "mimir_sa" {
  account_id   = "mimir-sa"
  display_name = "Mimir Service Account"
  project      = var.project_id
}

resource "google_storage_bucket_iam_member" "mimir_storage_admin" {
  bucket = google_storage_bucket.mimir_storage.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.mimir_sa.email}"
}

resource "google_service_account_iam_binding" "mimir_workload_identity" {
  service_account_id = google_service_account.mimir_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[mimir/mimir]"
  ]
}

# ------------------------------------------------------------------------------
# 3. Tempo Storage & IAM
# ------------------------------------------------------------------------------
resource "google_storage_bucket" "tempo_storage" {
  name          = "${var.project_id}-tempo-storage"
  location      = var.region
  force_destroy = true
  project       = var.project_id
  uniform_bucket_level_access = true
}

resource "google_service_account" "tempo_sa" {
  account_id   = "tempo-sa"
  display_name = "Tempo Service Account"
  project      = var.project_id
}

resource "google_storage_bucket_iam_member" "tempo_storage_admin" {
  bucket = google_storage_bucket.tempo_storage.name
  role   = "roles/storage.objectAdmin"
  member = "serviceAccount:${google_service_account.tempo_sa.email}"
}

resource "google_service_account_iam_binding" "tempo_workload_identity" {
  service_account_id = google_service_account.tempo_sa.name
  role               = "roles/iam.workloadIdentityUser"

  members = [
    "serviceAccount:${var.project_id}.svc.id.goog[tempo/tempo]"
  ]
}

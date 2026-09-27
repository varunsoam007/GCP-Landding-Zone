# ==============================================================================
# GCP Secret Manager Secrets for OAuth2 Proxy
# ==============================================================================

# Import existing Secret Manager secrets if already created in GCP
import {
  id = "projects/${var.project_id}/secrets/oauth2-client-id"
  to = google_secret_manager_secret.oauth2_client_id
}

import {
  id = "projects/${var.project_id}/secrets/oauth2-client-secret"
  to = google_secret_manager_secret.oauth2_client_secret
}

import {
  id = "projects/${var.project_id}/secrets/oauth2-cookie-secret"
  to = google_secret_manager_secret.oauth2_cookie_secret
}

resource "google_secret_manager_secret" "oauth2_client_id" {
  secret_id = "oauth2-client-id"
  project   = var.project_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "oauth2_client_id_version" {
  secret      = google_secret_manager_secret.oauth2_client_id.id
  secret_data = "dummy-client-id-replace-me"
}

resource "google_secret_manager_secret" "oauth2_client_secret" {
  secret_id = "oauth2-client-secret"
  project   = var.project_id

  replication {
    auto {}
  }
}

resource "google_secret_manager_secret_version" "oauth2_client_secret_version" {
  secret      = google_secret_manager_secret.oauth2_client_secret.id
  secret_data = "dummy-client-secret-replace-me"
}

resource "google_secret_manager_secret" "oauth2_cookie_secret" {
  secret_id = "oauth2-cookie-secret"
  project   = var.project_id

  replication {
    auto {}
  }
}

# The cookie secret must be a 16, 24, or 32 byte base64 encoded string
# "OQ6zP39u8X2p1l0hY1jNqV4a5B8s7D9f" (32 chars) base64 encoded -> "T1E2elAzOXU4WDJwMWwwaFkxak5xVjRhNUI4czdEOWY="
resource "google_secret_manager_secret_version" "oauth2_cookie_secret_version" {
  secret      = google_secret_manager_secret.oauth2_cookie_secret.id
  secret_data = "T1E2elAzOXU4WDJwMWwwaFkxak5xVjRhNUI4czdEOWY="
}

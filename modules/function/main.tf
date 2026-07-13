locals {
  name          = "${var.confident_application_name}-${var.confident_environment}"
  function_name = "${local.name}-codesandbox"
  sa_account    = "${var.confident_application_code}-${var.confident_environment_code}-sandbox-sa"
}

resource "google_service_account" "this" {
  account_id   = local.sa_account
  project      = var.confident_gcp_project_id
  display_name = "Confident AI code sandbox function"
}

resource "google_project_iam_member" "this" {
  for_each = toset([
    "roles/logging.logWriter",
    "roles/artifactregistry.reader",
  ])
  project = var.confident_gcp_project_id
  role    = each.value
  member  = "serviceAccount:${google_service_account.this.email}"
}

resource "google_cloudfunctions2_function" "this" {
  name        = local.function_name
  project     = var.confident_gcp_project_id
  location    = var.confident_gcp_region
  description = "Sandboxed code execution for Confident AI"

  build_config {
    runtime           = "custom"
    entry_point       = "execute"
    docker_repository = "projects/${var.confident_gcp_project_id}/locations/${var.confident_gcp_region}/repositories/${var.confident_ar_repository_name}"
  }

  service_config {
    max_instance_count    = 100
    min_instance_count    = 0
    available_memory      = var.confident_code_executor_memory
    available_cpu         = "1"
    timeout_seconds       = var.confident_code_executor_timeout_seconds
    ingress_settings      = "ALLOW_INTERNAL_ONLY"
    service_account_email = google_service_account.this.email
  }

  labels = var.confident_tags
}

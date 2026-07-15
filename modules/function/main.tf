locals {
  name         = "${var.confident_application_name}-${var.confident_environment}"
  service_name = "${local.name}-codesandbox"
  sa_account   = "${var.confident_application_code}-${var.confident_environment_code}-sandbox-sa"
  image        = "${var.confident_gcp_region}-docker.pkg.dev/${var.confident_gcp_project_id}/${var.confident_ar_repository_name}/${var.confident_code_executor_image_name}:${var.confident_code_executor_image_tag}"
}

resource "google_service_account" "this" {
  account_id   = local.sa_account
  project      = var.confident_gcp_project_id
  display_name = "Confident AI code sandbox"
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

resource "google_cloud_run_v2_service" "this" {
  name                = local.service_name
  project             = var.confident_gcp_project_id
  location            = var.confident_gcp_region
  ingress             = "INGRESS_TRAFFIC_ALL"
  deletion_protection = false

  template {
    service_account = google_service_account.this.email
    timeout         = "${var.confident_code_executor_timeout_seconds}s"

    scaling {
      min_instance_count = 0
      max_instance_count = 100
    }

    containers {
      image = local.image
      resources {
        limits = {
          cpu    = "1"
          memory = var.confident_code_executor_memory
        }
      }
    }
  }

  labels = var.confident_tags
}

resource "google_cloud_run_v2_service_iam_member" "app_invoker" {
  project  = var.confident_gcp_project_id
  location = var.confident_gcp_region
  name     = google_cloud_run_v2_service.this.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${var.confident_app_service_account_email}"
}

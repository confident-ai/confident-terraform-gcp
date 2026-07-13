locals {
  name          = "${var.confident_application_name}-${var.confident_environment}"
  db_identifier = "${var.confident_region_prefix}d${var.confident_database_type}${var.confident_application_code}${var.confident_environment_code}001"

  buckets = merge(
    {
      test_cases = "${local.name}-${var.confident_test_cases_bucket}-bucket"
      payloads   = "${local.name}-${var.confident_payloads_bucket}-bucket"
    },
    var.confident_clickhouse_backup_bucket_enabled ? {
      clickhouse_backup = "${local.name}-${var.confident_clickhouse_backup_bucket_name}-bucket"
    } : {},
  )

  app_sa_account = "${var.confident_application_code}-${var.confident_environment_code}-app-sa"
  eso_sa_account = "${var.confident_application_code}-${var.confident_environment_code}-eso-sa"
  secret_id      = "${local.name}-${var.confident_secrets_name}-secret"

  wi_member     = "serviceAccount:${var.confident_gcp_project_id}.svc.id.goog[${var.confident_service_account_namespace}/${var.confident_service_account_name}]"
  eso_wi_member = "serviceAccount:${var.confident_gcp_project_id}.svc.id.goog[${var.confident_service_account_namespace}/${var.confident_eso_service_account_name}]"
}

resource "random_password" "postgres" {
  length  = 24
  special = false
}

# ---------------------------------------------------------------------------
# Private Services Access — required for Cloud SQL private IP
# ---------------------------------------------------------------------------

resource "google_compute_global_address" "psa" {
  count         = var.confident_create_private_service_connection ? 1 : 0
  name          = "${local.name}-psa"
  project       = var.confident_gcp_project_id
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.confident_network_id
}

resource "google_service_networking_connection" "psa" {
  count                   = var.confident_create_private_service_connection ? 1 : 0
  network                 = var.confident_network_id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.psa[0].name]
}

# ---------------------------------------------------------------------------
# PostgreSQL (Cloud SQL)
# ---------------------------------------------------------------------------

resource "google_sql_database_instance" "this" {
  name                = local.db_identifier
  project             = var.confident_gcp_project_id
  region              = var.confident_gcp_region
  database_version    = var.confident_psql_version
  deletion_protection = var.confident_rds_deletion_protection

  settings {
    tier              = var.confident_psql_instance_class
    availability_type = var.confident_psql_availability_type
    disk_size         = var.confident_rds_allocated_storage
    disk_autoresize   = true
    user_labels       = var.confident_tags

    ip_configuration {
      ipv4_enabled    = false
      private_network = var.confident_network_id
      ssl_mode        = "ENCRYPTED_ONLY"
    }

    backup_configuration {
      enabled                        = true
      point_in_time_recovery_enabled = true
      backup_retention_settings {
        retained_backups = var.confident_rds_backup_retention_period
      }
    }
  }

  depends_on = [google_service_networking_connection.psa]
}

resource "google_sql_database" "this" {
  name     = var.confident_psql_db_name
  project  = var.confident_gcp_project_id
  instance = google_sql_database_instance.this.name
}

resource "google_sql_user" "this" {
  name     = var.confident_psql_username
  project  = var.confident_gcp_project_id
  instance = google_sql_database_instance.this.name
  password = random_password.postgres.result
}

# ---------------------------------------------------------------------------
# Object storage (GCS)
# ---------------------------------------------------------------------------

resource "google_storage_bucket" "this" {
  for_each                    = local.buckets
  name                        = each.value
  project                     = var.confident_gcp_project_id
  location                    = var.confident_gcp_region
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"
  labels                      = var.confident_tags

  versioning {
    enabled = true
  }
}

# ---------------------------------------------------------------------------
# App identity — GSA + Workload Identity binding + bucket access
# ---------------------------------------------------------------------------

resource "google_service_account" "app" {
  account_id   = local.app_sa_account
  project      = var.confident_gcp_project_id
  display_name = "Confident AI application"
}

resource "google_service_account_iam_member" "app_workload_identity" {
  service_account_id = google_service_account.app.name
  role               = "roles/iam.workloadIdentityUser"
  member             = local.wi_member
}

resource "google_storage_bucket_iam_member" "app" {
  for_each = google_storage_bucket.this
  bucket   = each.value.name
  role     = "roles/storage.objectAdmin"
  member   = "serviceAccount:${google_service_account.app.email}"
}

# ---------------------------------------------------------------------------
# Optional: empty Secret Manager secret + Workload Identity for External Secrets
# ---------------------------------------------------------------------------

resource "google_secret_manager_secret" "app" {
  count     = var.confident_create_secret_manager ? 1 : 0
  project   = var.confident_gcp_project_id
  secret_id = local.secret_id

  replication {
    auto {}
  }
  # No google_secret_manager_secret_version: created empty, populated out-of-band.
}

resource "google_service_account" "eso" {
  count        = var.confident_create_secret_manager ? 1 : 0
  account_id   = local.eso_sa_account
  project      = var.confident_gcp_project_id
  display_name = "Confident AI External Secrets Operator"
}

resource "google_service_account_iam_member" "eso_workload_identity" {
  count              = var.confident_create_secret_manager ? 1 : 0
  service_account_id = google_service_account.eso[0].name
  role               = "roles/iam.workloadIdentityUser"
  member             = local.eso_wi_member
}

resource "google_secret_manager_secret_iam_member" "eso" {
  count     = var.confident_create_secret_manager ? 1 : 0
  project   = var.confident_gcp_project_id
  secret_id = google_secret_manager_secret.app[0].secret_id
  role      = "roles/secretmanager.secretAccessor"
  member    = "serviceAccount:${google_service_account.eso[0].email}"
}

# ---------------------------------------------------------------------------
# Optional managed Redis (Memorystore) — alternative to the bundled StatefulSet
# ---------------------------------------------------------------------------

resource "google_redis_instance" "this" {
  count              = var.confident_managed_redis_enabled ? 1 : 0
  name               = "${local.name}-redis"
  project            = var.confident_gcp_project_id
  region             = var.confident_gcp_region
  tier               = var.confident_redis_tier
  memory_size_gb     = var.confident_redis_memory_size_gb
  redis_version      = var.confident_redis_version
  authorized_network = var.confident_network_id
  connect_mode       = "PRIVATE_SERVICE_ACCESS"
  labels             = var.confident_tags

  depends_on = [google_service_networking_connection.psa]
}

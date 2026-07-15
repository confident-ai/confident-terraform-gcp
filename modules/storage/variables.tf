# --- Naming ---
variable "confident_application_name" {
  type    = string
  default = "confidentai"
}

variable "confident_application_code" {
  type    = string
  default = "cai"
}

variable "confident_environment" {
  type    = string
  default = "stage"
}

variable "confident_environment_code" {
  type    = string
  default = "s"
}

variable "confident_region_prefix" {
  type    = string
  default = "dgcp"
}

variable "confident_database_type" {
  type    = string
  default = "pos"
}

# --- Project / location ---
variable "confident_gcp_project_id" {
  type = string
}

variable "confident_gcp_region" {
  type = string
}

variable "confident_tags" {
  type    = map(string)
  default = {}
}

# --- Networking (existing VPC) ---
variable "confident_network_id" {
  description = "VPC network self_link/id for Cloud SQL private IP."
  type        = string
}

variable "confident_create_private_service_connection" {
  description = "Create the Private Services Access peering Cloud SQL needs. Set false if the network already has one."
  type        = bool
  default     = true
}

# --- PostgreSQL (Cloud SQL) ---
variable "confident_psql_version" {
  type    = string
  default = "POSTGRES_17"
}

variable "confident_psql_instance_class" {
  type    = string
  default = "db-custom-2-7680"
}

variable "confident_psql_edition" {
  description = "Cloud SQL edition. ENTERPRISE pairs with db-custom-* tiers; ENTERPRISE_PLUS needs db-perf-optimized-N-* tiers."
  type        = string
  default     = "ENTERPRISE"
}

variable "confident_psql_db_name" {
  type    = string
  default = "confident_db"
}

variable "confident_psql_username" {
  type    = string
  default = "confident"
}

variable "confident_cloudsql_allocated_storage" {
  type    = number
  default = 20
}

variable "confident_cloudsql_backup_retention_period" {
  type    = number
  default = 7
}

variable "confident_cloudsql_deletion_protection" {
  type    = bool
  default = false
}

variable "confident_psql_availability_type" {
  type    = string
  default = "REGIONAL"
}

# --- Object storage (GCS) ---
variable "confident_test_cases_bucket" {
  type    = string
  default = "testcases"
}

variable "confident_payloads_bucket" {
  type    = string
  default = "payloads"
}

variable "confident_clickhouse_backup_bucket_enabled" {
  type    = bool
  default = false
}

variable "confident_clickhouse_backup_bucket_name" {
  type    = string
  default = "chbackups"
}

# --- App identity (GKE Workload Identity) ---
variable "confident_service_account_namespace" {
  type    = string
  default = "confident-ai"
}

variable "confident_service_account_name" {
  type    = string
  default = "confident"
}

# --- Optional secret store (Secret Manager for the External Secrets Operator) ---
variable "confident_create_secret_manager" {
  description = "Create an EMPTY Secret Manager secret + Workload Identity so ESO can read it. No value versions are written."
  type        = bool
  default     = false
}

variable "confident_secrets_name" {
  type    = string
  default = "confident"
}

variable "confident_eso_service_account_name" {
  type    = string
  default = "external-secrets-sa"
}

# --- Optional managed Redis (Memorystore) — alternative to the bundled StatefulSet ---
variable "confident_managed_redis_enabled" {
  description = "Provision Memorystore for Redis and output redis_url (set the chart's redis.internal=false, redis.externalUrl)."
  type        = bool
  default     = false
}

variable "confident_redis_tier" {
  description = "BASIC (single node) or STANDARD_HA (replicated)."
  type        = string
  default     = "STANDARD_HA"
}

variable "confident_redis_memory_size_gb" {
  type    = number
  default = 1
}

variable "confident_redis_version" {
  type    = string
  default = "REDIS_7_2"
}

variable "confident_psql_password" {
  description = "PostgreSQL password. Empty generates a random one."
  type        = string
  default     = ""
  sensitive   = true
}

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

variable "confident_tags" {
  type    = map(string)
  default = {}
}

# --- Project / location ---
variable "confident_gcp_project_id" {
  type = string
}

variable "confident_gcp_region" {
  type    = string
  default = "us-central1"
}

variable "confident_availability_zones" {
  type    = list(string)
  default = ["us-central1-a", "us-central1-b"]
}

# --- Networking (existing VPC — never created here) ---
variable "confident_network_name" {
  description = "Existing VPC network name (for GKE)."
  type        = string
}

variable "confident_network_id" {
  description = "Existing VPC network self_link/id (for Cloud SQL private IP)."
  type        = string
}

variable "confident_subnetwork_name" {
  description = "Existing subnetwork name for GKE nodes."
  type        = string
}

variable "confident_ip_range_pods" {
  description = "Existing secondary range name for pods."
  type        = string
}

variable "confident_ip_range_services" {
  description = "Existing secondary range name for services."
  type        = string
}

variable "confident_master_ipv4_cidr_block" {
  type    = string
  default = "172.16.0.0/28"
}

variable "confident_create_private_service_connection" {
  type    = bool
  default = true
}

# --- GKE cluster (always created) ---
variable "confident_kubernetes_version" {
  type    = string
  default = "1.34"
}

variable "confident_public_gke" {
  type    = bool
  default = false
}

variable "confident_gke_admin_user" {
  type    = string
  default = ""
}

variable "confident_node_machine_type" {
  type    = string
  default = "n2-standard-8"
}

variable "confident_node_image_type" {
  type    = string
  default = "COS_CONTAINERD"
}

variable "confident_node_group_min_size" {
  type    = number
  default = 2
}

variable "confident_node_group_max_size" {
  type    = number
  default = 8
}

variable "confident_node_group_desired_size" {
  type    = number
  default = 4
}

# --- Data plane — PostgreSQL ---
variable "confident_psql_version" {
  type    = string
  default = "POSTGRES_17"
}

variable "confident_psql_instance_class" {
  type    = string
  default = "db-custom-2-7680"
}

variable "confident_psql_db_name" {
  type    = string
  default = "confident_db"
}

variable "confident_psql_username" {
  type    = string
  default = "confident"
}

variable "confident_rds_allocated_storage" {
  type    = number
  default = 20
}

variable "confident_rds_backup_retention_period" {
  type    = number
  default = 7
}

variable "confident_rds_deletion_protection" {
  type    = bool
  default = false
}

# --- Data plane — object storage ---
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

# --- Code executor (Cloud Function) — created by default ---
variable "confident_code_executor_enabled" {
  type    = bool
  default = true
}

variable "confident_ar_repository_name" {
  description = "Artifact Registry repo with the code-sandbox image. Required when confident_code_executor_enabled=true."
  type        = string
  default     = ""
}

variable "confident_code_executor_memory" {
  type    = string
  default = "512Mi"
}

variable "confident_code_executor_timeout_seconds" {
  type    = number
  default = 300
}

# --- Optional secret store (Secret Manager) ---
variable "confident_create_secret_manager" {
  type    = bool
  default = false
}

variable "confident_secrets_name" {
  type    = string
  default = "confident"
}

variable "confident_eso_service_account_name" {
  type    = string
  default = "external-secrets-sa"
}

# --- Optional managed Redis (Memorystore) ---
variable "confident_managed_redis_enabled" {
  type    = bool
  default = false
}

variable "confident_redis_tier" {
  type    = string
  default = "STANDARD_HA"
}

variable "confident_redis_memory_size_gb" {
  type    = number
  default = 1
}

variable "confident_redis_version" {
  type    = string
  default = "REDIS_7_2"
}

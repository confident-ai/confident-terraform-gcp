locals {
  create_function = var.confident_code_executor_enabled
}

module "gke" {
  source = "./modules/gke"

  confident_application_name = var.confident_application_name
  confident_application_code = var.confident_application_code
  confident_environment      = var.confident_environment
  confident_environment_code = var.confident_environment_code
  confident_region_prefix    = var.confident_region_prefix

  confident_gcp_project_id     = var.confident_gcp_project_id
  confident_gcp_region         = var.confident_gcp_region
  confident_availability_zones = var.confident_availability_zones

  confident_network_name            = var.confident_network_name
  confident_subnetwork_name         = var.confident_subnetwork_name
  confident_ip_range_pods           = var.confident_ip_range_pods
  confident_ip_range_services       = var.confident_ip_range_services
  confident_master_ipv4_cidr_block  = var.confident_master_ipv4_cidr_block
  confident_kubernetes_version      = var.confident_kubernetes_version
  confident_public_gke              = var.confident_public_gke
  confident_gke_admin_user          = var.confident_gke_admin_user
  confident_node_machine_type       = var.confident_node_machine_type
  confident_node_image_type         = var.confident_node_image_type
  confident_node_group_min_size     = var.confident_node_group_min_size
  confident_node_group_max_size     = var.confident_node_group_max_size
  confident_node_group_desired_size = var.confident_node_group_desired_size
}

module "function" {
  source = "./modules/function"
  count  = local.create_function ? 1 : 0

  confident_application_name = var.confident_application_name
  confident_application_code = var.confident_application_code
  confident_environment      = var.confident_environment
  confident_environment_code = var.confident_environment_code
  confident_tags             = var.confident_tags

  confident_gcp_project_id                = var.confident_gcp_project_id
  confident_gcp_region                    = var.confident_gcp_region
  confident_ar_repository_name            = var.confident_ar_repository_name
  confident_code_executor_image_name      = var.confident_code_executor_image_name
  confident_code_executor_image_tag       = var.confident_code_executor_image_tag
  confident_code_executor_memory          = var.confident_code_executor_memory
  confident_code_executor_timeout_seconds = var.confident_code_executor_timeout_seconds

  # app SA (created in the storage layer) gets roles/run.invoker on the sandbox
  confident_app_service_account_email = module.storage.app_service_account_email
}

module "storage" {
  source = "./modules/storage"

  confident_application_name = var.confident_application_name
  confident_application_code = var.confident_application_code
  confident_environment      = var.confident_environment
  confident_environment_code = var.confident_environment_code
  confident_region_prefix    = var.confident_region_prefix
  confident_database_type    = var.confident_database_type
  confident_tags             = var.confident_tags

  confident_gcp_project_id = var.confident_gcp_project_id
  confident_gcp_region     = var.confident_gcp_region

  confident_network_id                        = var.confident_network_id
  confident_create_private_service_connection = var.confident_create_private_service_connection

  confident_psql_version                     = var.confident_psql_version
  confident_psql_instance_class              = var.confident_psql_instance_class
  confident_psql_edition                     = var.confident_psql_edition
  confident_psql_db_name                     = var.confident_psql_db_name
  confident_psql_username                    = var.confident_psql_username
  confident_psql_password                    = var.confident_psql_password
  confident_cloudsql_allocated_storage       = var.confident_cloudsql_allocated_storage
  confident_cloudsql_backup_retention_period = var.confident_cloudsql_backup_retention_period
  confident_cloudsql_deletion_protection     = var.confident_cloudsql_deletion_protection

  confident_test_cases_bucket                = var.confident_test_cases_bucket
  confident_payloads_bucket                  = var.confident_payloads_bucket
  confident_clickhouse_backup_bucket_enabled = var.confident_clickhouse_backup_bucket_enabled
  confident_clickhouse_backup_bucket_name    = var.confident_clickhouse_backup_bucket_name

  confident_service_account_namespace = var.confident_service_account_namespace
  confident_service_account_name      = var.confident_service_account_name

  confident_create_secret_manager    = var.confident_create_secret_manager
  confident_secrets_name             = var.confident_secrets_name
  confident_eso_service_account_name = var.confident_eso_service_account_name

  confident_managed_redis_enabled = var.confident_managed_redis_enabled
  confident_redis_tier            = var.confident_redis_tier
  confident_redis_memory_size_gb  = var.confident_redis_memory_size_gb
  confident_redis_version         = var.confident_redis_version

  depends_on = [module.gke]
}

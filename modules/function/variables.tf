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

variable "confident_gcp_project_id" {
  type = string
}

variable "confident_gcp_region" {
  type = string
}

variable "confident_ar_repository_name" {
  description = "Artifact Registry repository holding the code-sandbox container image."
  type        = string

  validation {
    condition     = var.confident_ar_repository_name != ""
    error_message = "confident_ar_repository_name is required when the code executor is enabled (confident_code_executor_enabled=true)."
  }
}

variable "confident_code_executor_image_name" {
  description = "Image name within the Artifact Registry repo (mirror of confidentai/confident-code-sandbox-gcp)."
  type        = string
  default     = "confident-code-sandbox-gcp"
}

variable "confident_code_executor_image_tag" {
  type    = string
  default = "latest"
}

variable "confident_app_service_account_email" {
  description = "App service account (Workload Identity) granted roles/run.invoker on the sandbox."
  type        = string
}

variable "confident_code_executor_memory" {
  type    = string
  default = "512Mi"
}

variable "confident_code_executor_timeout_seconds" {
  type    = number
  default = 300
}

variable "confident_tags" {
  type    = map(string)
  default = {}
}

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

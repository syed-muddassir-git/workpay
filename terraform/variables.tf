variable "project_id" {
  description = "Google Cloud Project ID"
  type        = string
}

variable "region" {
  description = "GCP region"
  type        = string
  default     = "us-central1"
}

variable "app_name" {
  description = "Cloud Run service name"
  type        = string
  default     = "todo-app"
}

variable "artifact_repository" {
  description = "Artifact Registry repository"
  type        = string
  default     = "docker-repo"
}

variable "db_instance_name" {
  description = "Cloud SQL instance"
  type        = string
  default     = "todo-db"
}

variable "db_name" {
  description = "Application database"
  type        = string
  default     = "todoapp"
}

variable "db_user" {
  description = "Database username"
  type        = string
  default     = "appuser"
}

variable "db_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

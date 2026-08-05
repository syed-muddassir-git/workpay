resource "google_cloud_run_v2_service" "todo_app" {
  name     = var.app_name
  location = var.region

  template {
    service_account = "219904781419-compute@developer.gserviceaccount.com"

    containers {
      image = "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_repository}/${var.app_name}:latest"

      ports {
        container_port = 3000
      }

      env {
        name  = "POSTGRES_HOST"
        value = "/cloudsql/${google_sql_database_instance.postgres.connection_name}"
      }

      env {
        name  = "POSTGRES_PORT"
        value = "5432"
      }

      env {
        name  = "POSTGRES_DB"
        value = var.db_name
      }

      env {
        name  = "POSTGRES_USER"
        value = var.db_user
      }

      env {
        name  = "POSTGRES_PASSWORD"
        value = var.db_password
      }

      volume_mounts {
        name       = "cloudsql"
        mount_path = "/cloudsql"
      }
    }
  }
}

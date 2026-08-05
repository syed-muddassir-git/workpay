output "cloud_run_url" {
  value = google_cloud_run_v2_service.todo_app.uri
}

output "artifact_registry" {
  value = google_artifact_registry_repository.docker_repo.registry_uri
}

output "cloud_sql_connection_name" {
  value = google_sql_database_instance.postgres.connection_name
}

output "cloud_sql_instance" {
  value = google_sql_database_instance.postgres.name
}

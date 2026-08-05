resource "google_sql_database_instance" "postgres" {
  name             = var.db_instance_name
  region           = var.region
  database_version = "POSTGRES_16"

  settings {
    tier = "db-f1-micro"
  }

  deletion_protection = true
}

resource "google_sql_database" "database" {
  name     = var.db_name
  instance = google_sql_database_instance.postgres.name
}

resource "google_sql_user" "appuser" {
  name     = var.db_user
  instance = google_sql_database_instance.postgres.name
  password = var.db_password

  lifecycle {
    ignore_changes = [
      password
    ]
  }
}

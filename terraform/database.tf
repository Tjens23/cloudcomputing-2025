resource "google_sql_database" "database" {
  name     = "backend-database"
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_database_instance" "instance" {
  name             = "database-instance"
  region           = var.region
  database_version = var.sql_version

  settings {
    tier = "db-f1-micro"
  }

  deletion_protection = false
}

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

  deletion_protection  = false
}

resource "google_sql_user" "users" {
  name     = var.db_user
  instance = google_sql_database_instance.instance.name
  password = random_password.db_password.result
}

resource "random_password" "db_password" {
  length  = 16
  special = true
}
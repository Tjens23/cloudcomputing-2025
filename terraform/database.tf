variable "db_user" {
  description = "The database user name"
  type        = string
  default     = "admin"
}

resource "google_sql_database" "database" {
  name     = "threedata"
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
  
  depends_on = [google_service_networking_connection.private_vpc_connection]
}

resource "google_sql_user" "users" {
  name     = var.db_user
  instance = google_sql_database_instance.instance.name
  password = random_password.db_password.result
}

# IAM user for backend service account
resource "google_sql_user" "backend_iam_user" {
  name     = google_service_account.backend_sa.email
  instance = google_sql_database_instance.instance.name
  type     = "CLOUD_IAM_SERVICE_ACCOUNT"
  
  depends_on = [google_sql_database_instance.instance]
}


resource "random_password" "db_password" {
  length  = 16
  special = true
}

output "db_password" {
  value    = random_password.db_password.result
  sensitive = true
}

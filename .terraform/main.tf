variable region {
    type    = string
    default = "europe-north2"
}

provider "google" {
    project = "cloudcomputing-terraform"
    region  = var.region
}

// *********** Frontend Service ***********

resource "google_cloud_run_service" "frontend_service" {
    name     = "frontend-service"
    location = var.region
}

// *********** Backend Service ***********

resource "google_cloud_run_service" "backend_service" {
    name     = "backend-service"
    location = var.region
}

resource "google_sql_database" "database" {
  name     = "backend-database"
  instance = google_sql_database_instance.instance.name
}

resource "google_sql_database_instance" "instance" {
  name             = "database-instance"
  region           = var.region
  database_version = "MYSQL_8_0"

  settings {
    tier = "db-f1-micro"
  }

  deletion_protection  = true
}

// *********** Network Services ***********

resource "google_compute_network" "vpc_network" {
    name                    = "vpc-network"
    auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "subnet" {
    name          = "vpc-subnet"
    ip_cidr_range = "10.0.0.0/24"
    network       = google_compute_network.vpc_network.name
}

resource "google_vpc_access_connector" "vpc_connector" {
    name         = "vpc-connector"
    region       = var.region
    network      = google_compute_network.vpc_network.name
    ip_cidr_range = "10.8.0.0/28"
}

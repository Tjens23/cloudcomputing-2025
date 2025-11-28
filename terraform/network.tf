# vpc network are just called this idk why google_compute_network
resource "google_compute_network" "frontend-vpc" {
name = "frontend-vpc-name"
auto_create_subnetworks = false
}

# vpc network are just called this idk why google_compute_network
resource "google_compute_network" "backend" {
name = "backend-vpc-name"
auto_create_subnetworks = false
}

resource "google_compute_network" "frontend" {
name = "backend-frontend-name"
auto_create_subnetworks = false
}

# todo change subnet ranges to being different
resource "google_compute_subnetwork""backend-subnet" {
name = "backend-subnet"
ip_cidr_range = "10.0.0.0/24"
region = var.region
network =google_compute_network.backend.id
}

resource "google_compute_subnetwork""frontend-subnet" {
 name = "frontend-subnet"
ip_cidr_range = "10.0.1.0/24"
region = var.region
network =google_compute_network.frontend.id
}

resource "google_compute_subnetwork""database-subnet" {
 name = "database-subnet"
ip_cidr_range = "10.0.2.0/24"
region = var.region
network =google_compute_network.backend.id
}

# resource "google_vpc_access_connector" "connector" {
#   name          = "vpc-con"
#   ip_cidr_range = "10.8.0.0/28"
#   network       = "default"
#   min_instances = 2
#   max_instances = 3
# }

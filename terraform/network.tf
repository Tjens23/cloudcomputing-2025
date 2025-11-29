
# vpc network are just called this idk why google_compute_network
resource "google_compute_network" "backend" {
name = "backend-vpc-name"
auto_create_subnetworks = false
}

resource "google_compute_network" "frontend" {
name = "backend-frontend-name"
auto_create_subnetworks = false
}

resource "google_compute_subnetwork""backend-subnet" {
name = "backend-subnet"
ip_cidr_range = "10.0.0.0/24"
region = var.region
network = google_compute_network.backend.id
}

resource "google_compute_subnetwork""frontend-subnet" {
 name = "frontend-subnet"
ip_cidr_range = "10.0.1.0/24"
region = var.region
network = google_compute_network.frontend.id
}

resource "google_compute_subnetwork""database-subnet" {
 name = "database-subnet"
ip_cidr_range = "10.0.2.0/24"
region = var.region
network = google_compute_network.backend.id
}

#  connector alternative to ingress

# resource "google_vpc_access_connector" "connector" {
#   name          = "vpc-con"
#   ip_cidr_range = "10.8.0.0/28"
#   network       = "default"
#   min_instances = 2
#   max_instances = 3
# }

# add firewall rule to backend allowing connection in from other vpc eg. frontend
resource "google_compute_firewall" "backend-firewall" {
  project = var.project
  name    = "backend-to-frontend"
  network = google_compute_network.backend.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  # which ranges to open up for right?
  source_ranges = ["10.0.1.0/24"]
}

# add firewall rule to frontend allowing connection from the public
resource "google_compute_firewall" "frontend-firewall" {
  project = var.project
  name    = "frontend-backend"
  network = google_compute_network.frontend.id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }
  # which ranges to open up for right?
  source_ranges = ["10.0.0.0/24"]
}

# add vpc peering #

# frontend to backend vpc
resource "google_compute_network_peering" "frontend-to-backend" {
  name         = "backendpeerer"
  network      = google_compute_network.frontend.id
  peer_network = google_compute_network.backend.id
}

# frontend to backend vpc
resource "google_compute_network_peering" "backend-to-frontend" {
  name         = "frontendpeerer"
  network      = google_compute_network.backend.id
  peer_network = google_compute_network.frontend.id
}


# vpc network are just called this idk why google_compute_network
resource "google_compute_network" "vpc" {
  name                    = "vpc-name"
  auto_create_subnetworks = false
  
  # This helps with proper cleanup during destroy
  lifecycle {
    ignore_changes = []
    prevent_destroy = false
  }
}

# Reserve IP range for Cloud SQL private service connection
resource "google_compute_global_address" "private_ip_address" {
  name          = "cloudsql-peering-range"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc.id
}


resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
  
  depends_on = [google_compute_global_address.private_ip_address]
  
  lifecycle {
    ignore_changes = all
    prevent_destroy = false
  }
}

resource "google_compute_subnetwork""backend-subnet" {
  name = "backend-subnet"
  ip_cidr_range = "10.1.1.0/24"
  region = var.region
  network = google_compute_network.vpc.id
}

resource "google_compute_subnetwork""frontend-subnet" {
  name = "frontend-subnet"
  ip_cidr_range = "10.2.1.0/24"
  region = var.region
  network = google_compute_network.vpc.id
}


#  connector alternative to ingress


# connector for accessing network, this is for frontend connecting to backend
resource "google_compute_subnetwork" "backend-connector-subnet" {
  name          = "backend-connector-subnet"
  ip_cidr_range = "10.3.1.0/28"
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_compute_subnetwork" "frontend-connector-subnet" {
  name          = "frontend-connector-subnet"
  ip_cidr_range = "10.4.1.0/28"
  region        = var.region
  network       = google_compute_network.vpc.id
}

resource "google_vpc_access_connector" "to_backend" {
  name   = "vpc-back"
  region = var.region

  depends_on = [
    google_compute_network.vpc,
    google_compute_subnetwork.backend-connector-subnet
  ]

  subnet {
    name = google_compute_subnetwork.backend-connector-subnet.name
  }

  machine_type   = "e2-standard-4"
  min_instances  = 2
  max_instances  = 3
}

resource "google_vpc_access_connector" "to_frontend" {
  name   = "vpc-front"
  region = var.region

  depends_on = [
    google_compute_network.vpc,
    google_compute_subnetwork.frontend-connector-subnet
  ]

  subnet {
    name = google_compute_subnetwork.frontend-connector-subnet.name
  }

  machine_type   = "e2-standard-4"
  min_instances  = 2
  max_instances  = 3
}

# TODO check if vpc_access connect from backend to database works
# resource "google_vpc_access_connector" "to_frontend" {
#   name          = "vpc-front"
#   # ip_cidr_range = "0.0.0.0/28"
#   # network       = "frontend"
#   subnet {
#     name = google_compute_subnetwork.frontend-subnet.name
#   }
# # machine_type = "e2-standard-4"
#   min_instances = 2
#   max_instances = 3
# }

# add firewall rule to backend allowing connection in from other vpc eg. frontend
# resource "google_compute_firewall" "backend-firewall" {
#   project = var.project
#   name    = "backend-to-frontend"
#   network = google_compute_network.backend.id

#   allow {
#     protocol = "tcp"
#     ports    = ["22"]
#   }
#   # which ranges to open up for right?
#   source_ranges = ["10.0.1.0/24"]
# }

# # add firewall rule to frontend allowing connection from the public
# resource "google_compute_firewall" "frontend-firewall" {
#   project = var.project
#   name    = "frontend-backend"
#   network = google_compute_network.frontend.id
#   allow {
#     protocol = "tcp"
#     ports    = ["22"]
#   }
#   # which ranges to open up for right?
#   source_ranges = ["10.0.0.0/24"]
# }

# add vpc peering, not used in this commit we use 1 vpc with 2 subnets#

# frontend to backend vpc
# resource "google_compute_network_peering" "frontend-to-backend" {
#   name         = "backendpeerer"
#   network      = google_compute_network.frontend.id
#   peer_network = google_compute_network.backend.id
# }

# frontend to backend vpc
# resource "google_compute_network_peering" "backend-to-frontend" {
#   name         = "frontendpeerer"
#   network      = google_compute_network.backend.id
#   peer_network = google_compute_network.frontend.id
# }

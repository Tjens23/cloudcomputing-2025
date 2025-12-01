resource "google_project_iam_member" "cloud_run_vpc_access_agent" {
  project = var.project
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:service-${var.project_number}@serverless-robot-prod.iam.gserviceaccount.com"
}

resource "google_cloud_run_v2_service" "backend_service" {
    name     = "backend-service"
    location = var.region
    deletion_protection = false

  depends_on = [
    google_project_iam_member.cloud_run_vpc_access_agent,
    google_compute_subnetwork.backend-subnet # Ensure the subnetwork is created first
    ]



  template {
    containers {
      image = var.backend_image
    }
    vpc_access {
      network_interfaces {
        network    = google_compute_network.backend.id
        subnetwork = google_compute_subnetwork.backend-subnet.id
      }
    }
  }
}

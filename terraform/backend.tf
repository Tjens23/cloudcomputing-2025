# resource "google_project_iam_member" "cloud_run_vpc_access_agent" {
#   # The project where the network/subnetwork exists
#   project = var.project

#   # The required role for the Cloud Run Service Agent
#   role    = "roles/run.vpcAccessUser"

#   # The Cloud Run Service Agent (replace PROJECT_NUMBER)
#   member  = "serviceAccount:service-${var.project_number}@gcp-sa-cloudrun.iam.gserviceaccount.com"
# }

resource "google_cloud_run_v2_service" "backend_service" {
  name     = "backend-service"
  location = var.region
  deletion_protection = false



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

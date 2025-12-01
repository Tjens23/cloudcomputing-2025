resource "google_cloud_run_v2_service" "frontend_service" {
  name     = "frontend-service"
  location = var.region

  # depends_on = [
  #   google_artifact_registry_repository.frontend,
  # google_cloud_run_v2_service.backend

  # ]
  template {
    containers {
      image = var.frontend_image
    }
    vpc_access {
      network_interfaces {
        network    = google_compute_network.frontend.id
        subnetwork = google_compute_subnetwork.frontend-subnet.id
      }
    }
  }
}

resource "google_cloud_run_v2_service_iam_member" "frontend_public_invoker" {
    name        = google_cloud_run_v2_service.frontend_service.name
    location    = google_cloud_run_v2_service.frontend_service.location
    role        = "roles/run.invoker"
    member      = "allUsers"
}

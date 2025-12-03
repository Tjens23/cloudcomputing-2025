resource "google_cloud_run_v2_service" "frontend_service" {
    name     = "frontend-service"
    location = var.region
    deletion_protection = false

  depends_on = [
    google_artifact_registry_repository.frontend,
    google_cloud_run_v2_service.backend_service,
    google_compute_network.vpc,
    google_compute_subnetwork.frontend-connector-subnet,
    google_vpc_access_connector.to_frontend
  ]

  timeouts {
    create = "30m"
    update = "30m"
  }

  template {
    containers {
      image = var.frontend_image
    }
    vpc_access {
      connector = google_vpc_access_connector.to_frontend.id
      egress = "ALL_TRAFFIC" # Or "PRIVATE_RANGES_ONLY"
      # ingress = "ALL_TRAFFIC" # Or "PRIVATE_RANGES_ONLY"
    }

  }
}

resource "google_cloud_run_v2_service_iam_member" "frontend_public_invoker" {
    name        = google_cloud_run_v2_service.frontend_service.name
    location    = google_cloud_run_v2_service.frontend_service.location
    role        = "roles/run.invoker"
    member      = "allUsers"
}

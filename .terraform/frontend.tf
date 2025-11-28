resource "google_cloud_run_v2_service" "frontend_service" {
    name     = "frontend-service"
    location = var.region
    
    template {
        containers {
            image = var.frontend_image
        }
    }
}

resource "google_cloud_run_v2_service_iam_member" "frontend_public_invoker" {
    name        = google_cloud_run_v2_service.frontend_service.name
    location    = google_cloud_run_v2_service.frontend_service.location
    role        = "roles/run.invoker"
    member      = "allUsers"
}

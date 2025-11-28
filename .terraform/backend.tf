resource "google_cloud_run_v2_service" "backend_service" {
    name     = "backend-service"
    location = var.region
    
    template {
        containers {
            image = var.backend_image
        }
    }
}

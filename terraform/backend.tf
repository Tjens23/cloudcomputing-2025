resource "google_cloud_run_v2_service" "backend_service" {
    name     = "backend-service"
    location = var.region

    template {
        containers {
            image = var.backend_image
        }
      vpc_access{
      network_interfaces {
        network = "backend"
        subnetwork = "backend-subnet"
      }
      }
    }
    }
}

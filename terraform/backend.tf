resource "google_project_iam_member" "cloud_run_vpc_access_agent" {
  project = var.project
  role    = "roles/run.vpcAccessUser"
  member  = "serviceAccount:service-1028655243443@gcp-sa-cloudrun.iam.gserviceaccount.com"
}

resource "google_cloud_run_v2_service" "backend_service" {
    name     = "backend-service"
    location = var.region

  depends_on = [
    google_project_iam_member.cloud_run_vpc_access_agent,
    google_compute_subnetwork.backend-subnet # Ensure the subnetwork is created first
    ]


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

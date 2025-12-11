resource "google_project_iam_member" "cloud_run_vpc_access_agent" {
  project = var.project
  role    = "roles/compute.networkUser"
  member  = "serviceAccount:service-${var.project_number}@serverless-robot-prod.iam.gserviceaccount.com"
}

# Removed cloud_services_agent_editor - Google manages this service account automatically
# Reference: https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/google_project_iam

resource "time_sleep" "wait_for_connector" {
  depends_on      = [
    google_vpc_access_connector.to_backend,
    google_project_iam_member.cloud_run_vpc_access_agent
  ]
  create_duration = "120s"
}

resource "google_cloud_run_v2_service" "backend_service" {
    name     = "backend-service"
    location = var.region
    deletion_protection = false

  depends_on = [
    google_project_iam_member.cloud_run_vpc_access_agent,
    google_compute_network.vpc,
    google_compute_subnetwork.backend-connector-subnet,
    google_vpc_access_connector.to_backend,
    time_sleep.wait_for_connector
    ]

  timeouts {
    create = "30m"
    update = "30m"
  }

  template {
    containers {
      image = var.backend_image
    }
    vpc_access {
      connector = google_vpc_access_connector.to_backend.id
      egress = "PRIVATE_RANGES_ONLY"
    }
  }
}

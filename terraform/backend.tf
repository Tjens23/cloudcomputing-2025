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
    service_account = google_service_account.backend_sa.email
    
    containers {
      image = var.backend_image
      
      env {
        name  = "DB_NAME"
        value = google_sql_database.database.name
      }
      env {
        name  = "INSTANCE_CONNECTION_NAME"
        value = google_sql_database_instance.instance.connection_name
      }
      env {
        name  = "DB_IAM_USER"
        value = google_service_account.backend_sa.email
      }
    }
    vpc_access {
      connector = google_vpc_access_connector.to_backend.id
      egress = "PRIVATE_RANGES_ONLY"
    }
  }
}

# Allow frontend service account to invoke backend
resource "google_cloud_run_v2_service_iam_member" "backend_invoker" {
  name     = google_cloud_run_v2_service.backend_service.name
  location = google_cloud_run_v2_service.backend_service.location
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.frontend_sa.email}"
}

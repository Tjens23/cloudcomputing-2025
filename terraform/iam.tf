resource "google_project_iam_binding" "editors" {
  project = var.project
  role    = "roles/editor"

  members = [
    "user:mathiasydesdu@gmail.com",
    "user:hopetobylol@gmail.com",
    "user:Mathias.rojleskov@gmail.com",
    "user:Phillip713dk@gmail.com",
    "serviceAccount:717236969498-compute@developer.gserviceaccount.com",
    "serviceAccount:717236969498@cloudservices.gserviceaccount.com",
  ]
}

# Service account for frontend
resource "google_service_account" "frontend_sa" {
  account_id   = "frontend-service-account"
  display_name = "Frontend Service Account"
}

# Service account for backend
resource "google_service_account" "backend_sa" {
  account_id   = "backend-service-account"
  display_name = "Backend Service Account"
}
resource "google_artifact_registry_repository" "backend" {
  location      = var.region
  repository_id = "backend-repo"
  description   = "example docker repository"
  format        = "DOCKER"
}

resource "google_artifact_registry_repository" "frontend" {
  location      = var.region
  repository_id = "frontend-repo"
  description   = "example docker repository"
  format        = "DOCKER"
}

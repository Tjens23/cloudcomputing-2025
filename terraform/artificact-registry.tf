resource "google_artifact_registry_repository" "backend" {
  location      = var.region
  repository_id = "backend-repo"
  description   = "example docker repository"
  format        = "DOCKER"
}

# original project has a registry for each image
# import {
#   id = "projects/cloudcomputing-471208/locations/europe-north1/repositories/backend-repo"
#   to = google_artifact_registry_repository.backend
# }

resource "google_artifact_registry_repository" "frontend" {
  location      = var.region
  repository_id = "frontend-repo"
  description   = "example docker repository"
  format        = "DOCKER"
}
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/resources/artifact_registry_repository#import
# import {
#   id = "projects/cloudcomputing-471208/locations/europe-north1/repositories/cloud-run-source-deploy"
#   to = google_artifact_registry_repository.frontend
# }

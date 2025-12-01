variable "region" {
    type    = string
    default = "europe-north2"
}

variable project {
    type    = string
    default = "cloudcomputing-terraform"
}

variable project_number {
  type = string
  default = "1028655243443"
}
variable frontend_image {
    type    = string
    default = "europe-north2-docker.pkg.dev/cloudcomputing-terraform/frontend-repo/frontend"
}

variable backend_image {
    type    = string
    default = "europe-north2-docker.pkg.dev/cloudcomputing-terraform/backend-repo/backend"
}

variable sql_version {
    type    = string
    default = "MYSQL_8_0"
}

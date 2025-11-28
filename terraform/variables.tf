variable "region" {
    type    = string
    default = "europe-north2"
}

variable project {
    type    = string
    default = "cloudcomputing-terraform"
}

variable frontend_image {
    type    = string
    default = "gcr.io/cloudcomputing-terraform/frontend:latest"
}

variable backend_image {
    type    = string
    default = "gcr.io/cloudcomputing-terraform/backend:latest"
}

variable sql_version {
    type    = string
    default = "MYSQL_8_0"
}

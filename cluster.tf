module "build" {
  source = "./google_build"
  project = "${var.project}"
  repo_name = "${var.repo_name}"
}

module "gke" {
  source = "./gcp_kubernetes"

  billing_account = "${var.billing_account}"
  project = "${var.project}"
  client_email = "${var.client_email}"

}

variable "project" {
  type    = "string"
  default = ""
}

variable "repo_name" {
  type    = "string"
  default = ""
}


variable "billing_account" {
  type = "string"
}

variable "client_email" {
  type = "string"
}


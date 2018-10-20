
provider "google" {
  region = "${var.region}"
  credentials = "${file("/Users/ernesto/.config/gcloud/terraform-ernesto.json")}"
  project     = "${random_id.id.hex}"
  region      = "${var.region}"
}

resource "random_id" "id" {
  byte_length = 4
  prefix      = "${var.project_name}-"
}


resource "null_resource" "show_info" {
  provisioner "local-exec" {
    command = "gcloud info"
   # interpreter = ["/bin/bash"]
    environment = {
      GOOGLE_PROJECT = "${var.project_name}"
      GOOGLE_APPLICATION_CREDENTIALS = "${var.credentials_file}"
    }
  }
}

resource "google_project" "project" {
  name            = "${var.project_name}"
  project_id      = "${random_id.id.hex}"
  billing_account = "${var.billing_account}"
  org_id          = "${var.org_id}"
}

#resource "google_project_services" "project" {
#  project = "${var.project_name}"
#  services = "${var.project_services}"
#  depends_on = ["google_project.project"]
#}
data "google_iam_policy" "admin" {
  binding {
    role = "roles/compute.instanceAdmin"

    members = [
      "serviceAccount:${var.service_account}",
    ]
  }
  binding {
    role = "roles/iam.serviceAccountUser"

    members = [
      "serviceAccount:${var.service_account}",
      "user:ernesto.suarez@raminatrans.com",
      "user:arturo.cases@raminatrans.com"
    ]
  }
}

resource "google_project_service" "project" {
  count = "${length(var.project_services)}"
  project = "${random_id.id.hex}"
  service = "${element(var.project_services, count.index)}"
}

output "project_id" {
  value = "${google_project.project.project_id}"
}



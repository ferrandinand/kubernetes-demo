provider "google" {
  region  = "${var.region}"
  zone    = "${var.zone}"
  project = "${var.project}"
}

resource "random_id" "random" {
  prefix      = "golondrinaio-"
  byte_length = "8"
}

# Create the project
#resource "google_project" "golondrinaio" {
#  name            = "${random_id.random.hex}"
#  project_id      = "${random_id.random.hex}"
  #org_id          = "${var.org_id}"
#  billing_account = "${var.billing_account}"
#}


resource "google_service_account" "golondrinaio-server" {
  account_id   = "golondrinaio-server"
  display_name = "golondrinaio Server"
  #project      = "${google_project.golondrinaio.project_id}"
  project = "${var.project}"
}


resource "google_service_account_key" "golondrinaio" {
  service_account_id = "${google_service_account.golondrinaio-server.name}"
}


resource "google_project_iam_member" "service-account" {
  count   = "${length(var.service_account_iam_roles)}"
  #project      = "${google_project.golondrinaio.project_id}"
  project = "${var.project}"
  role    = "${element(var.service_account_iam_roles, count.index)}"
  member  = "serviceAccount:${google_service_account.golondrinaio-server.email}"
}


resource "google_project_service" "service" {
  count   = "${length(var.project_services)}"
  #project      = "${google_project.golondrinaio.project_id}"
  project = "${var.project}"
  service = "${element(var.project_services, count.index)}"

  disable_on_destroy = false
}

data "google_container_engine_versions" "versions" {
  zone = "${var.zone}"
}

resource "google_container_cluster" "golondrinaio" {
  name    = "golondrinaio"
  #project      = "${google_project.golondrinaio.project_id}"
  project = "${var.project}"
  zone    = "${var.zone}"

  initial_node_count = "${var.num_golondrinaio_servers}"

  min_master_version = "${data.google_container_engine_versions.versions.latest_master_version}"
  node_version       = "${data.google_container_engine_versions.versions.latest_node_version}"

  logging_service    = "${var.kubernetes_logging_service}"
  monitoring_service = "${var.kubernetes_monitoring_service}"

  node_config {
    machine_type    = "${var.instance_type}"

    service_account = "${google_service_account.golondrinaio-server.email}"

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/compute",
      "https://www.googleapis.com/auth/monitoring",
      "https://www.googleapis.com/auth/logging.write",
      "https://www.googleapis.com/auth/devstorage.read_only",
    ]

    tags = ["golondrinaio"]
  }

  depends_on = [
    "google_project_service.service",
    "google_project_iam_member.service-account",
  ]
}



provider "kubernetes" {
  host     = "${google_container_cluster.golondrinaio.endpoint}"
  username = "${google_container_cluster.golondrinaio.master_auth.0.username}"
  password = "${google_container_cluster.golondrinaio.master_auth.0.password}"

  client_certificate     = "${base64decode(google_container_cluster.golondrinaio.master_auth.0.client_certificate)}"
  client_key             = "${base64decode(google_container_cluster.golondrinaio.master_auth.0.client_key)}"
  cluster_ca_certificate = "${base64decode(google_container_cluster.golondrinaio.master_auth.0.cluster_ca_certificate)}"
}

resource "null_resource" "apply" {
  triggers {
    host                   = "${md5(google_container_cluster.golondrinaio.endpoint)}"
    username               = "${md5(google_container_cluster.golondrinaio.master_auth.0.username)}"
    password               = "${md5(google_container_cluster.golondrinaio.master_auth.0.password)}"
    client_certificate     = "${md5(google_container_cluster.golondrinaio.master_auth.0.client_certificate)}"
    client_key             = "${md5(google_container_cluster.golondrinaio.master_auth.0.client_key)}"
    cluster_ca_certificate = "${md5(google_container_cluster.golondrinaio.master_auth.0.cluster_ca_certificate)}"
  }

provisioner "local-exec" {
    command = <<EOF
gcloud container clusters get-credentials "${google_container_cluster.golondrinaio.name}" --zone="${google_container_cluster.golondrinaio.zone}" --project="${var.project}"
CONTEXT="gke_${var.project}_${google_container_cluster.golondrinaio.zone}_${google_container_cluster.golondrinaio.name}" kubectl create clusterrolebinding myname-cluster-admin-binding --clusterrole=cluster-admin --user="${var.client_email}"
EOF
  }
}

#resource "google_compute_address" "golondrinaio" {
#  name    = "golondrinaio-lb"
#  region  = "${var.region}"
#  project = "${var.project}"
#  #project      = "${google_project.golondrinaio.project_id}"
#
#  depends_on = ["google_project_service.service"]
#}
#

#data "google_compute_zones" "available" {}
#
#resource "google_compute_instance" "default" {
#  project      = "${var.gcp_project}"
# # zone         = "${var.gcp_region}"
#  zone         = "${data.google_compute_zones.available.names[0]}"
#  name         = "tf-compute-1"
#  machine_type = "f1-micro"
#
#  boot_disk {
#    initialize_params {
#      image = "ubuntu-1604-xenial-v20170328"
#    }
#  }
#
#  network_interface {
#    network       = "default"
#    access_config = {}
#  }
#}
#
#output "instance_id" {
#  value = "${google_compute_instance.default.self_link}"
#}
module "cluster_basico" {
  #
  #source = "../modules/terraform-google-kubernetes-engine"
  source = "google-terraform-modules/kubernetes-engine/google"

  version = "1.17.0"

  general = {
    name    = "${var.cluster_name}"
    env     = "${var.cluster_env}"
    zone    = "${var.zone}"
    project = "${var.project_id}"
  }

  master = {
    username = "${var.cluster_k8s_username}"

    #  password = "${random_string.password.result}"
    password = "${var.cluster_k8s_password}"
  }

  default_node_pool = {
    node_count = 3
    remove     = false

    #CUSTOM OPTIONS
    preemtible = true
    private    = true
  }

  # Optional in case we have a default pool
  node_pool = [
    {
      machine_type   = "${var.machine_type}"
      disk_size_gb   = 20
      node_count     = 3
      min_node_count = 1
      max_node_count = 4
      preemtible     = true
      private        = true
    },
    {
      disk_size_gb   = 30
      node_count     = 2
      min_node_count = 1
      max_node_count = 3
      preemtible     = true
      private        = true
    },
  ]
}

resource "random_string" "password" {
  length  = 16
  special = true
  number  = true
  lower   = true
  upper   = true
}

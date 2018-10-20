module "cluster_basico" {
  source  = "google-terraform-modules/kubernetes-engine/google"
  version = "1.17.0"

  general = {
    name    = "${var.cluster_name}"
    env     = "${var.cluster_env}"
    zone    = "${var.zone}"
    project = "${random_id.id.hex}"
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

    #   service_account = "${var.service_account}"
  }

  # Optional in case we have a default pool
  node_pool = [
    {
      machine_type   = "${var.machine_type}"
      disk_size_gb   = 20
      node_count     = 3
      min_node_count = 2
      max_node_count = 4
      preemtible     = true
      private        = true

      #  service_account = "${var.service_account}"
    },
  ]

  #,
  #{
  #  disk_size_gb   = 30
  #  node_count     = 2
  #  min_node_count = 1
  #  max_node_count = 3
  #  preemtible = true
  #  private = true
  #  service_account = "terraform@ernesto-terraform-adm.iam.gserviceaccount.com"
  #},   
}

resource "random_string" "password" {
  length  = 16
  special = true
  number  = true
  lower   = true
  upper   = true
}

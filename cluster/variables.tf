variable "project_name" {
  description = "The name of the GCP Project where all resources will be launched."
  default     = "cluster-istio-demo"
}

variable "project_id" {
  description = "The ID of the GCP Project where all resources will be launched."
  default     = "cluster-istio-demo"
}

variable "org_id" {
  description = "Organization ID at GCP"
  default     = "321376830469"
}

variable "billing_account" {
  description = "The billing account for this project"
  default     = "01AA8B-6F0F9C-1F92B5"
}

variable "region" {
  description = "The region in which all GCP resources will be launched."
  default     = "europe-west2"
}

variable "zone" {
  description = "The specific zone"
  default     = "europe-west2-a"
}

variable "service_account" {
  description = "The name of the service account used for perform the tasks"
  default     = ""
}

variable "cluster_name" {
  description = "GKE cluster name"
  default     = "mi-cluster"
}

variable "cluster_env" {
  description = "Cluster Enviroment"
  default     = "prod"
}

variable "credentials_file" {
  description = "Credentials JSON of the service account"
  default     = ""
}

variable "cluster_k8s_username" {
  description = "Username for adminstrator at Kubernetes"
  default     = "admin"
}

variable "cluster_k8s_password" {
  description = "Username for adminstrator at Kubernetes"
  default     = "cambiamePorDios.."
}

variable "machine_type" {
  description = "size of the machine"
  default     = "g1-small"
}

variable "project_services" {
  description = "List of services to this project"

  default = [
    "cloudresourcemanager.googleapis.com",
    "cloudbilling.googleapis.com",
    "iam.googleapis.com",
    "compute.googleapis.com",
    "oslogin.googleapis.com",
    "storage-api.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudapis.googleapis.com",
    "container.googleapis.com",
    "containerregistry.googleapis.com",
    "logging.googleapis.com",
    "monitoring.googleapis.com",
    "dns.googleapis.com",
  ]
}

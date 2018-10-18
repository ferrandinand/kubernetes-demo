terraform {
 backend "gcs" {
   bucket  = "terraform-ernesto"
   prefix  = "terraform/state"
   project = "terraform-ernesto"
 }
}

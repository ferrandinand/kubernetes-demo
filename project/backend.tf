terraform {
 backend "gcs" {
   bucket  = "terraform-wedoops"
   prefix  = "terraform/state"
   project = "terraform-wedoops"
 }
}

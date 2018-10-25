#output "address" {
#  value = "${google_compute_address.golondrinaio.address}"
#}
#
#output "project" {
#  value = "${google_project.golondrinaio.project_id}"
#}

output "region" {
  value = "${var.region}"
}

output "zone" {
  value = "${var.zone}"
}

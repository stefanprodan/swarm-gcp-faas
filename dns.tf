//resource "google_dns_managed_zone" "swarm" {
//  name     = "${terraform.workspace}-zone"
//  dns_name = "${var.domain}"
//}
//
//resource "google_dns_record_set" "swarm" {
//  name = "swarm.${google_dns_managed_zone.swarm.dns_name}"
//  type = "A"
//  ttl  = 300
//
//  managed_zone = "${google_dns_managed_zone.swarm.name}"
//
//  rrdatas = [
//    "${google_compute_instance.manager.network_interface.0.access_config.0.assigned_nat_ip}",
//    "${google_compute_instance.manager_follower.0.network_interface.0.access_config.0.assigned_nat_ip}",
//    "${google_compute_instance.manager_follower.1.network_interface.0.access_config.0.assigned_nat_ip}"
//  ]
//}

resource "google_dns_record_set" "swarm" {
  count = "${var.enable_dns == "true" ? 1 : 0}"
  name  = "${var.subdomain}"
  type  = "A"
  ttl   = 300

  managed_zone = "${var.dns_zone}"

  rrdatas = [
    "${google_compute_instance.manager.network_interface.0.access_config.0.assigned_nat_ip}",
    "${google_compute_instance.manager_follower.0.network_interface.0.access_config.0.assigned_nat_ip}",
    "${google_compute_instance.manager_follower.1.network_interface.0.access_config.0.assigned_nat_ip}",
  ]
}

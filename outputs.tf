output "swarm_managers" {
  value = "${concat(google_compute_instance.manager.*.name, google_compute_instance.manager.*.network_interface.address)}"
}

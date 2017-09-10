output "workspace" {
  value = "${terraform.workspace}"
}

output "swarm_manager_ip" {
  value = "${google_compute_instance.manager.0.network_interface.0.access_config.0.assigned_nat_ip}"
}

output "swarm_managers" {
  value = "${concat(google_compute_instance.manager.*.name, google_compute_instance.manager.*.network_interface.0.access_config.0.assigned_nat_ip)}"
}

output "swarm_workers" {
  value = "${concat(google_compute_instance.worker.*.name, google_compute_instance.worker.*.network_interface.0.access_config.0.assigned_nat_ip)}"
}

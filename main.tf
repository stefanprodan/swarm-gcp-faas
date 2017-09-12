provider "google" {
  credentials = "${file("account.json")}"
  project     = "${var.project}"
  region      = "${var.region}"
}

resource "google_compute_network" "swarm" {
  name                    = "${terraform.workspace}-network"
  auto_create_subnetworks = true
}

data "template_file" "docker_conf" {
  template = "${file("conf/docker.tpl")}"

  vars {
    ip = "${var.docker_api_ip}"
  }
}

data "external" "swarm_tokens" {
  program = ["./scripts/fetch-tokens.sh"]

  query = {
    host = "${google_compute_instance.manager.0.network_interface.0.access_config.0.assigned_nat_ip}"
    user = "${var.ssh_user}"
  }

  depends_on = ["google_compute_instance.manager"]
}

resource "google_compute_address" "manager" {
  count = 1
  name  = "${terraform.workspace}-manager-ip-${count.index + 1}"
}

resource "google_compute_instance" "manager" {
  count        = 1
  name         = "${terraform.workspace}-manager-${count.index + 1}"
  machine_type = "${var.manager_machine_type}"
  zone         = "${element(var.zones, count.index)}"

  tags = ["swarm", "manager"]

  boot_disk {
    initialize_params {
      image = "${var.machine_image}"
      size  = "50"
    }
  }

  network_interface {
    network = "${google_compute_network.swarm.name}"

    access_config {
      nat_ip = "${element(google_compute_address.manager.*.address, count.index)}"
    }
  }

  metadata {
    swarm = "manager"
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  connection {
    type = "ssh"
    user = "${var.ssh_user}"
  }

  provisioner "file" {
    content     = "${data.template_file.docker_conf.rendered}"
    destination = "/tmp/docker.conf"
  }

  provisioner "file" {
    source      = "scripts/install-docker-ce.sh"
    destination = "/tmp/install-docker-ce.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/systemd/system/docker.service.d",
      "sudo mv /tmp/docker.conf /etc/systemd/system/docker.service.d/docker.conf",
      "sudo chmod +x /tmp/install-docker-ce.sh",
      "sudo /tmp/install-docker-ce.sh ${var.docker_version}",
      "curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh",
      "sudo bash install-logging-agent.sh",
      "sudo docker swarm init --advertise-addr ${self.network_interface.0.address}",
    ]
  }

  depends_on = ["google_compute_firewall.ssh", "google_compute_firewall.internal"]
}

resource "google_compute_address" "manager_follower" {
  count = "${var.manager_instance_count - 1}"
  name  = "${terraform.workspace}-manager-ip-${count.index + 2}"
}

resource "google_compute_instance" "manager_follower" {
  count        = "${var.manager_instance_count - 1}"
  name         = "${terraform.workspace}-manager-${count.index + 2}"
  machine_type = "${var.manager_machine_type}"
  zone         = "${element(var.zones, count.index + 1)}"

  tags = ["swarm", "manager"]

  boot_disk {
    initialize_params {
      image = "${var.machine_image}"
      size  = "50"
    }
  }

  network_interface {
    network = "${google_compute_network.swarm.name}"

    access_config {
      nat_ip = "${element(google_compute_address.manager_follower.*.address, count.index)}"
    }
  }

  metadata {
    swarm = "manager"
  }

  service_account {
    scopes = ["cloud-platform"]
  }

  connection {
    type = "ssh"
    user = "${var.ssh_user}"
  }

  provisioner "file" {
    content     = "${data.template_file.docker_conf.rendered}"
    destination = "/tmp/docker.conf"
  }

  provisioner "file" {
    source      = "scripts/install-docker-ce.sh"
    destination = "/tmp/install-docker-ce.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/systemd/system/docker.service.d",
      "sudo mv /tmp/docker.conf /etc/systemd/system/docker.service.d/docker.conf",
      "sudo chmod +x /tmp/install-docker-ce.sh",
      "sudo /tmp/install-docker-ce.sh ${var.docker_version}",
      "curl -sSO https://dl.google.com/cloudagents/install-logging-agent.sh",
      "sudo bash install-logging-agent.sh",
      "sudo docker swarm join --token ${data.external.swarm_tokens.result.manager} ${google_compute_instance.manager.0.network_interface.0.address}:2377",
    ]
  }

  # leave swarm on destroy
  provisioner "remote-exec" {
    when = "destroy"

    inline = [
      "sudo docker swarm leave --force",
    ]

    on_failure = "continue"
  }
}

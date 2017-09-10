resource "google_compute_instance" "worker" {
  count        = "${var.worker_instance_count}"
  name         = "${terraform.workspace}-worker-${count.index + 1}"
  machine_type = "${var.machine_type}"
  zone         = "${var.region_zone}"

  tags = ["swarm", "worker"]

  boot_disk {
    initialize_params {
      image = "${var.machine_image}"
    }
  }

  network_interface {
    network = "default"

    access_config {
    }
  }

  metadata {
    swarm = "worker"
  }

  service_account {
    scopes = ["compute-ro", "storage-ro"]
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

  # install DOcker and join the swarm
  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/systemd/system/docker.service.d",
      "sudo mv /tmp/docker.conf /etc/systemd/system/docker.service.d/docker.conf",
      "sudo chmod +x /tmp/install-docker-ce.sh",
      "sudo /tmp/install-docker-ce.sh ${var.docker_version}",
      "sudo docker swarm join --token ${data.external.swarm_tokens.result.worker} ${google_compute_instance.manager.0.network_interface.0.address}:2377",
    ]
  }

  # leave swarm on destroy
  provisioner "remote-exec" {
    when = "destroy"

    inline = [
      "sudo docker swarm leave",
    ]

    on_failure = "continue"
  }

  # remove node on destroy
  provisioner "remote-exec" {
    when = "destroy"

    inline = [
      "sudo docker node rm --force ${self.name}",
    ]

    on_failure = "continue"

    connection {
      type = "ssh"
      user = "${var.ssh_user}"
      host = "${google_compute_instance.manager.0.network_interface.0.access_config.0.assigned_nat_ip}"
    }
  }
}

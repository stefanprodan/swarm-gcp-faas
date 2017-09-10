resource "google_compute_instance" "manager" {
  count        = 1
  name         = "${terraform.workspace}-manager-${count.index + 1}"
  machine_type = "${var.machine_type}"
  zone         = "${var.region_zone}"

  tags = ["swarm", "manager"]

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
    swarm = "manager"
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

  provisioner "remote-exec" {
    inline = [
      "sudo mkdir -p /etc/systemd/system/docker.service.d",
      "sudo mv /tmp/docker.conf /etc/systemd/system/docker.service.d/docker.conf",
      "sudo chmod +x /tmp/install-docker-ce.sh",
      "sudo /tmp/install-docker-ce.sh ${var.docker_version}",
      "sudo docker swarm init --advertise-addr ${self.network_interface.0.address}",
    ]
  }
}

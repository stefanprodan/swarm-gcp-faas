resource "google_compute_firewall" "ssh" {
  name    = "${terraform.workspace}-ssh"
  network = "${google_compute_network.swarm.name}"

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["swarm"]
}

resource "google_compute_firewall" "internal" {
  name    = "${terraform.workspace}-internal"
  network = "${google_compute_network.swarm.name}"

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }

  allow {
    protocol = "udp"
    ports    = ["1-65535"]
  }

  allow {
    protocol = "icmp"
  }

  source_tags = ["swarm"]
  target_tags = ["swarm"]
}

resource "google_compute_firewall" "http" {
  name    = "${terraform.workspace}-https"
  network = "${google_compute_network.swarm.name}"

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["swarm"]
}

resource "google_compute_firewall" "management" {
  name    = "${terraform.workspace}-management"
  network = "${google_compute_network.swarm.name}"

  allow {
    protocol = "tcp"
    ports    = ["1-65535"]
  }

  source_ranges = ["${var.management_ip_range}"]
  target_tags   = ["swarm"]
}

resource "google_compute_firewall" "docker" {
  name    = "${terraform.workspace}-docker-api"
  network = "${google_compute_network.swarm.name}"

  allow {
    protocol = "tcp"
    ports    = ["2375"]
  }

  source_ranges = ["${var.management_ip_range}"]
  target_tags   = ["swarm"]
}

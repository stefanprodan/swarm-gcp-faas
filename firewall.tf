resource "google_compute_firewall" "http" {
  name = "http"
  network = "default"

  allow {
    protocol = "tcp"
    ports = ["80", "443"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["swarm"]
}

resource "google_compute_firewall" "docker" {
  name = "docker"
  network = "default"

  allow {
    protocol = "tcp"
    ports = ["2375"]
  }

  source_ranges = ["${var.docker_api_ip_allow}"]
  target_tags = ["swarm"]
}

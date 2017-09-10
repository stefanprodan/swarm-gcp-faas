variable "docker_version" {
  default = "17.06.0~ce-0~ubuntu"
}

variable "region" {
  default = "europe-west3"
}

variable "region_zone" {
  default = "europe-west3-a"
}

variable "project" {
  default = "dx-general"
}

variable "machine_image" {
  default = "ubuntu-os-cloud/ubuntu-1604-lts"
}

variable "machine_type" {
  default = "n1-standard-1"
}

variable "ssh_user" {
  default = "stefan"
}

variable "worker_instance_count" {
  default = 2
}

variable "docker_api_ip" {
  default = "0.0.0.0"
}

variable "docker_api_ip_allow" {
  default = "86.120.86.211"
}

resource "google_compute_instance" "vm_instance" {
  name         = "terraform-instance"
  machine_type = "g1-small"
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
  }
  network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
}

resource "google_storage_bucket" "example_bucket" {
  name     = "terraform-state-kosheliuk"
  location = "EU"
  force_destroy = true
  uniform_bucket_level_access = true
  
  website {
    main_page_suffix = "index.html"
    not_found_page   = "404.html"
  }
  versioning {
      enabled = true
  }
 }

resource "google_compute_network" "vpc_network" {
  name = "petclinic-vpc-tf"
}

resource "google_compute_subnetwork" "subnetwork" {
  name = "petclinic-subnet-tf-eu-west1"
  ip_cidr_range = "10.24.5.0/24"
  region = "europe-west1"
  network = google_compute_network.vpc_network.name
}

resource "google_compute_firewall" "rules_ssh" {
  project     = "gcp-2022-1-phase2-kosheliuk"
  name        = "petclinic-allow-ssh-tf"
  network     = "petclinic-vpc-tf"
  description = "Creates firewall rule ssh targeting tagged instances"

  allow {
    protocol  = "tcp"
    ports     = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["ssh"]
}

resource "google_compute_firewall" "rules_http" {
  project     = "gcp-2022-1-phase2-kosheliuk"
  name        = "petclinic-allow-http-tf"
  network     = "petclinic-vpc-tf"
  description = "Creates firewall rule http targeting tagged instances"

  allow {
    protocol  = "tcp"
    ports     = ["8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["http"]
}

resource "google_compute_address" "ip_address" {
  name = "petclinic-public-ip-tf"
}

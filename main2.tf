resource "google_compute_instance" "default" {
  name         = "petclinic-app-tf"
  machine_type = "g1-small"
  zone         = "europe-west1"

  tags = ["ssh", "web"]

  boot_disk {
    initialize_params {
      image = "petclinic-instance-image-v2"
      labels = {
        my_label = "value"
      }
    }
  }
   network_interface {
    network = google_compute_network.vpc_network.name
    access_config {
    }
  }
  }
  
resource "google_compute_address" "ip_address1" {
  name = "petclinic-public-ip-tf"
}

resource "google_compute_network" "default" {
    name = "petclinic-vpc-tf"
}

resource "google_compute_subnetwork" "default" {
    name = "petclinic-subnet-tf-eu-west1"
    region = "europe-west1"
    ip_cidr_range = "10.24.5.0/24"
    network = google_compute_network.vpc_network.name
}

resource "google_service_account" "sa" {
  account_id   = "petclinic-sa"
  display_name = "Petclinic Service Account"
}

### VPC
resource "google_compute_network" "default1" {
  name                    = "petclinic-vpc-tf"
  auto_create_subnetworks = "false"
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "EXTERNAL"
  prefix_length = 16
  network = google_compute_network.vpc_network.name
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.name
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}


### INSTANCE
resource "google_sql_database_instance" "instance" {
  name             = "petclinic-db-tf-1979"
  region           = "europe-west1"
  database_version = "MYSQL_5_7"

  depends_on = [google_service_networking_connection.private_vpc_connection]

  settings {
    tier = "db-f1-micro"

    ip_configuration {
        ipv4_enabled    = true
        private_network = "default"

        authorized_networks {
          name = google_compute_network.default1.id
          value = "0.0.0.0/0"
        }
      }
  }
}


### DATABASE
resource "google_sql_database" "database" {
  name     = "petclinic"
  instance = google_sql_database_instance.instance.name
}


### USER
resource "google_sql_user" "users" {
  name     = "petclinic"
  password = "petclinic"
  instance = google_sql_database_instance.instance.name
}

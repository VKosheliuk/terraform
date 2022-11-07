provider "google" {
  credentials = "${file("gcp-2022-1-phase2-kosheliuk-788301fe12f1.json")}"
  
  project = "gcp-2022-1-phase2-kosheliuk"
  region  = "europe-west1"
  zone    = "europe-west1-b"
}
resource "google_compute_network" "vpc" {
  name                    = "${var.gcp_project}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "cluster_subnet" {
  name          = "${var.gcp_project}-cluster-subnet"
  region        = var.gcp_region
  network       = google_compute_network.vpc.name
  ip_cidr_range = var.gcp_cidr_range
  private_ip_google_access = true
}

resource "google_compute_router" "router" {
  name = "${var.gcp_project}-vpn-router"
  network = google_compute_network.vpc.id
  bgp {
    asn = var.gcp_asn
  }
}

resource "google_compute_router_nat" "nat" {
  name = "${var.gcp_project}-nat-gw"
  region = var.gcp_region
  router = google_compute_router.router.name
  nat_ip_allocate_option = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"
}


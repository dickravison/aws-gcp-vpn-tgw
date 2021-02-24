# Create the HA gateway
resource "google_compute_ha_vpn_gateway" "ha_gw" {
  name     = "${var.gcp_project}-aws-gw"
  network  = google_compute_network.vpc.id
}

resource "google_compute_external_vpn_gateway" "ext_gw" {
  name            = "aws-vpn"
  redundancy_type = "FOUR_IPS_REDUNDANCY"
  description     = "AWS Transit GW"

  interface {
    id         = 0
    ip_address = aws_vpn_connection.vpn[0].tunnel1_address
  }
  
  interface {
    id         = 1
    ip_address = aws_vpn_connection.vpn[0].tunnel2_address
  }

  interface {
    id         = 2
    ip_address = aws_vpn_connection.vpn[1].tunnel1_address
  }

  interface {
    id         = 3
    ip_address = aws_vpn_connection.vpn[1].tunnel2_address
  }

}

resource "google_compute_vpn_tunnel" "tun-0-0" {
  name                            = "tun-0-0"
  shared_secret                   = aws_vpn_connection.vpn[0].tunnel1_preshared_key
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gw.id
  vpn_gateway_interface           = 0
  peer_external_gateway           = google_compute_external_vpn_gateway.ext_gw.id
  peer_external_gateway_interface = 0
  router                          = google_compute_router.router.name
  ike_version                     = 2
}

resource "google_compute_vpn_tunnel" "tun-0-1" {
  name                            = "tun-0-1"
  shared_secret                   = aws_vpn_connection.vpn[0].tunnel2_preshared_key
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gw.id
  vpn_gateway_interface           = 0
  peer_external_gateway           = google_compute_external_vpn_gateway.ext_gw.id
  peer_external_gateway_interface = 1
  router                          = google_compute_router.router.name
  ike_version                     = 2
}

resource "google_compute_vpn_tunnel" "tun-1-0" {
  name                            = "tun-1-0"
  shared_secret                   = aws_vpn_connection.vpn[1].tunnel1_preshared_key
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gw.id
  vpn_gateway_interface           = 1
  peer_external_gateway           = google_compute_external_vpn_gateway.ext_gw.id
  peer_external_gateway_interface = 2
  router                          = google_compute_router.router.name
  ike_version                     = 2
}

resource "google_compute_vpn_tunnel" "tun-1-1" {
  name                            = "tun-1-1"
  shared_secret                   = aws_vpn_connection.vpn[1].tunnel2_preshared_key
  vpn_gateway                     = google_compute_ha_vpn_gateway.ha_gw.id
  vpn_gateway_interface           = 1
  peer_external_gateway           = google_compute_external_vpn_gateway.ext_gw.id
  peer_external_gateway_interface = 3
  router                          = google_compute_router.router.name
  ike_version                     = 2
}

resource "google_compute_router_interface" "int-0" {
  name       = "int-1"
  router     = google_compute_router.router.name
  ip_range   = "${aws_vpn_connection.vpn[0].tunnel1_cgw_inside_address}/30"
  vpn_tunnel = google_compute_vpn_tunnel.tun-0-0.name
}

resource "google_compute_router_interface" "int-1" {
  name       = "int-2"
  router     = google_compute_router.router.name
  ip_range   = "${aws_vpn_connection.vpn[0].tunnel2_cgw_inside_address}/30"
  vpn_tunnel = google_compute_vpn_tunnel.tun-0-1.name
}

resource "google_compute_router_interface" "int-2" {
  name       = "int-3"
  router     = google_compute_router.router.name
  ip_range   = "${aws_vpn_connection.vpn[1].tunnel1_cgw_inside_address}/30"
  vpn_tunnel = google_compute_vpn_tunnel.tun-1-0.name
}

resource "google_compute_router_interface" "int-3" {
  name       = "int-4"
  router     = google_compute_router.router.name
  ip_range   = "${aws_vpn_connection.vpn[1].tunnel2_cgw_inside_address}/30"
  vpn_tunnel = google_compute_vpn_tunnel.tun-1-1.name
}

resource "google_compute_router_peer" "peer-0" {
  name                      = "peer-0"
  interface                 = google_compute_router_interface.int-0.name
  peer_ip_address           = aws_vpn_connection.vpn[0].tunnel1_vgw_inside_address
  peer_asn                  = aws_vpn_connection.vpn[0].tunnel1_bgp_asn
  router                    = google_compute_router.router.name
  advertised_route_priority = 100
}

resource "google_compute_router_peer" "peer-1" {
  name                      = "peer-1"
  interface                 = google_compute_router_interface.int-1.name
  peer_ip_address           = aws_vpn_connection.vpn[0].tunnel2_vgw_inside_address
  peer_asn                  = aws_vpn_connection.vpn[0].tunnel2_bgp_asn
  router                    = google_compute_router.router.name
  advertised_route_priority = 100
}

resource "google_compute_router_peer" "peer-2" {
  name                      = "peer-2"
  interface                 = google_compute_router_interface.int-2.name
  peer_ip_address           = aws_vpn_connection.vpn[1].tunnel1_vgw_inside_address
  peer_asn                  = aws_vpn_connection.vpn[1].tunnel1_bgp_asn
  router                    = google_compute_router.router.name
  advertised_route_priority = 100
}

resource "google_compute_router_peer" "peer-3" {
  name                      = "peer-3"
  interface                 = google_compute_router_interface.int-3.name
  peer_ip_address           = aws_vpn_connection.vpn[1].tunnel2_vgw_inside_address
  peer_asn                  = aws_vpn_connection.vpn[1].tunnel2_bgp_asn
  router                    = google_compute_router.router.name
  advertised_route_priority = 100
}


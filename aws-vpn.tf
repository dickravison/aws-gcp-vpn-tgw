resource "aws_customer_gateway" "cgw-gcp" {
  count      = 2
  bgp_asn    = var.gcp_asn
  ip_address = google_compute_ha_vpn_gateway.ha_gw.vpn_interfaces[count.index].ip_address
  type       = "ipsec.1"
}

resource "aws_vpn_connection" "vpn" {
  count               = 2
  transit_gateway_id  = aws_ec2_transit_gateway.tgw.id
  customer_gateway_id = aws_customer_gateway.cgw-gcp[count.index].id
  type                = "ipsec.1"
}

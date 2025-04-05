resource "oci_core_vcn" "main_vcn" {
  cidr_block     = "10.0.0.0/16"
  compartment_id = var.oci_compartment_id
  display_name   = "vcn-main"
  dns_label      = "main"
}

resource "oci_core_subnet" "subnet_0" {
  cidr_block     = "10.0.0.0/24"
  compartment_id = var.oci_compartment_id
  display_name   = "subnet-0"
  dns_label      = "sub0"
  route_table_id = oci_core_vcn.main_vcn.default_route_table_id
  vcn_id         = oci_core_vcn.main_vcn.id
}

resource "oci_core_internet_gateway" "main_gateway" {
  compartment_id = var.oci_compartment_id
  display_name   = "Internet Gateway vcn-main"
  vcn_id         = oci_core_vcn.main_vcn.id
}

resource "oci_core_default_route_table" "main_routes" {
  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.main_gateway.id
  }
  manage_default_resource_id = oci_core_vcn.main_vcn.default_route_table_id
}

resource "oci_core_default_security_list" "main_security_list" {

  ingress_security_rules {
    description = "allow ICMP from everywhere"
    source      = "0.0.0.0/0"
    protocol    = "1" // ICMP
  }

  ingress_security_rules {
    description = "allow http"
    source      = "0.0.0.0/0"
    protocol    = "6" // TCP
    tcp_options {
      min = 80
      max = 80
    }
  }

  ingress_security_rules {
    description = "allow https"
    source      = "0.0.0.0/0"
    protocol    = "6" // TCP
    tcp_options {
      min = 443
      max = 443
    }
  }

  ingress_security_rules {
    description = "allow tailscale easy-NAT"
    source      = "0.0.0.0/0"
    protocol    = "17" // UDP
    udp_options {
      min = 41641
      max = 41641
    }
  }

  egress_security_rules {
    description = "allow all egress"
    destination = "0.0.0.0/0"
    protocol    = "all"
  }

  manage_default_resource_id = oci_core_vcn.main_vcn.default_security_list_id
}

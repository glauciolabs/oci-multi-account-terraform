# modules/oci-network/main.tf

resource "oci_core_vcn" "vcn" {
  compartment_id = var.compartment_id
  cidr_block     = var.vcn_cidr
  display_name   = "${var.prefix}-vcn"
  dns_label      = "${var.prefix}vcn"
}

resource "oci_core_internet_gateway" "internet_gateway" {
  count          = var.create_public_subnet ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.prefix}-igw"
  enabled        = true
}

resource "oci_core_route_table" "public_route_table" {
  count          = var.create_public_subnet ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.prefix}-public-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_internet_gateway.internet_gateway[0].id
  }
}

resource "oci_core_subnet" "public_subnet" {
  count             = var.create_public_subnet ? 1 : 0
  compartment_id    = var.compartment_id
  vcn_id            = oci_core_vcn.vcn.id
  cidr_block        = var.public_subnet_cidr
  display_name      = "${var.prefix}-public-subnet"
  route_table_id    = oci_core_route_table.public_route_table[0].id
  security_list_ids = [oci_core_security_list.security_list[0].id]
}

resource "oci_core_nat_gateway" "nat_gateway" {
  count          = var.create_private_subnet ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.prefix}-nat"
}

resource "oci_core_route_table" "private_route_table" {
  count          = var.create_private_subnet ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.prefix}-private-rt"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = oci_core_nat_gateway.nat_gateway[0].id
  }
}

resource "oci_core_subnet" "private_subnet" {
  count                        = var.create_private_subnet ? 1 : 0
  compartment_id               = var.compartment_id
  vcn_id                       = oci_core_vcn.vcn.id
  cidr_block                   = var.private_subnet_cidr
  display_name                 = "${var.prefix}-private-subnet"
  route_table_id               = oci_core_route_table.private_route_table[0].id
  security_list_ids            = [oci_core_security_list.security_list[0].id]
  prohibit_public_ip_on_vnic   = true
}

resource "oci_core_security_list" "security_list" {
  count          = var.create_public_subnet || var.create_private_subnet ? 1 : 0
  compartment_id = var.compartment_id
  vcn_id         = oci_core_vcn.vcn.id
  display_name   = "${var.prefix}-security-list"

  egress_security_rules {
    destination = "0.0.0.0/0"
    protocol    = "all"
    description = "Allow all outbound traffic"
  }

  ingress_security_rules {
    protocol    = "6"
    source      = "0.0.0.0/0"
    description = "Allow SSH from anywhere"
    tcp_options {
      min = 22
      max = 22
    }
  }

  ingress_security_rules {
    protocol    = "6"
    source      = var.vcn_cidr
    description = "Allow OCFS2 heartbeat traffic between instances"
    tcp_options {
      min = 7777
      max = 7777
    }
  }

  dynamic "ingress_security_rules" {
    for_each = var.nlb_listener_port != null ? [var.nlb_listener_port] : []
    content {
      protocol    = "6"
      source      = "0.0.0.0/0"
      description = "Allow traffic from NLB listener"
      tcp_options {
        min = ingress_security_rules.value
        max = ingress_security_rules.value
      }
    }
  }
}

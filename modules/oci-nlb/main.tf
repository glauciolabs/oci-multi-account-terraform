# modules/oci-nlb/main.tf

resource "oci_network_load_balancer_network_load_balancer" "nlb" {
  compartment_id = var.compartment_id
  display_name   = "${var.display_name_prefix}-nlb"
  subnet_id      = var.subnet_id
  is_private     = false
}

resource "oci_network_load_balancer_backend_set" "backend_set" {
  name                     = "${var.display_name_prefix}-bset"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  policy                   = "FIVE_TUPLE"
  is_preserve_source       = true

  health_checker {
    protocol = "TCP"
    port     = var.health_check_port
  }
}

resource "oci_network_load_balancer_listener" "listener" {
  name                     = "${var.display_name_prefix}-listener"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  default_backend_set_name = oci_network_load_balancer_backend_set.backend_set.name
  port                     = var.listener_port
  protocol                 = "TCP"
}

resource "oci_network_load_balancer_backend" "backends" {
  for_each = var.backend_instance_map

  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  backend_set_name         = oci_network_load_balancer_backend_set.backend_set.name
  port                     = var.listener_port
  target_id                = each.value
  name                     = "backend-${var.display_name_prefix}-${each.key}"
}

# modules/oci-nlb/main.tf

terraform {
  required_version = ">= 1.13.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 7.19.0"
    }
  }
}

resource "oci_network_load_balancer_network_load_balancer" "nlb" {
  compartment_id = var.compartment_id
  display_name   = "${var.display_name_prefix}-nlb"
  subnet_id      = var.subnet_id
  is_private     = false
}

resource "oci_network_load_balancer_backend_set" "backend_set" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  name                     = "${var.display_name_prefix}-bset"
  policy                   = "FIVE_TUPLE"
  is_preserve_source       = true

  health_checker {
    protocol           = var.health_check_protocol
    port               = var.health_check_port
    interval_in_millis = var.health_check_interval
    timeout_in_millis  = var.health_check_timeout
    retries            = var.health_check_retries

    url_path            = var.health_check_protocol == "HTTP" || var.health_check_protocol == "HTTPS" ? var.health_check_path : null
    return_code         = var.health_check_protocol == "HTTP" || var.health_check_protocol == "HTTPS" ? var.health_check_return_code : null
    response_body_regex = var.health_check_protocol == "HTTP" || var.health_check_protocol == "HTTPS" ? var.health_check_response_regex : null
  }
}

resource "oci_network_load_balancer_listener" "listener" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  name                     = "${var.display_name_prefix}-listener"
  default_backend_set_name = oci_network_load_balancer_backend_set.backend_set.name

  protocol = "ANY"
  port     = var.listener_port
}

resource "oci_network_load_balancer_backend" "backends" {
  for_each = var.backend_instance_map

  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.nlb.id
  backend_set_name         = oci_network_load_balancer_backend_set.backend_set.name
  name                     = "backend-${var.display_name_prefix}-${each.key}"
  target_id                = each.value
  port                     = 0
}

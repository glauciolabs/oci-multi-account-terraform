# modules/oci-ampere-instance/main.tf

terraform {
  required_version = ">= 1.13.0"
  required_providers {
    oci = {
      source  = "oracle/oci"
      version = ">= 7.19.0"
    }
  }
}

resource "oci_core_instance" "ampere_instance" {
  count               = var.instance_count
  availability_domain = var.availability_domain
  compartment_id      = var.compartment_id
  shape               = var.instance_shape
  display_name        = "${var.instance_prefix}-${count.index + 1}"

  shape_config {
    memory_in_gbs = var.instance_memory_gb
    ocpus         = var.instance_ocpus
  }

  source_details {
    source_type             = "image"
    source_id               = var.image_ocid
    boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  }

  agent_config {
    is_management_disabled = false
    is_monitoring_disabled = false
    plugins_config {
      name          = "Compute Instance Monitoring"
      desired_state = "ENABLED"
    }
    plugins_config {
      name          = "Block Volume Management"
      desired_state = "ENABLED"
    }
  }

  create_vnic_details {
    subnet_id                 = var.subnet_id
    assign_public_ip          = var.assign_public_ip
    assign_private_dns_record = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_key
    user_data           = var.user_data
  }

  timeouts {
    create = "30m"
  }
}

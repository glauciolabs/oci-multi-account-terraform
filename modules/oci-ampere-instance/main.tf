# modules/oci-ampere-instance/main.tf

resource "oci_core_instance" "ampere_instance" {
  count                = var.instance_count  # Usar variável dinâmica
  availability_domain  = var.availability_domain
  compartment_id       = var.compartment_id
  shape                = var.instance_shape  # Usar shape dinâmico
  display_name         = "${var.instance_prefix}-${count.index + 1}"
  is_pv_encryption_in_transit_enabled = true
  
  # Configuração dinâmica baseada no shape
  dynamic "shape_config" {
    for_each = can(regex("Flex$", var.instance_shape)) ? [1] : []
    content {
      memory_in_gbs = var.instance_memory_gb
      ocpus         = var.instance_ocpus
    }
  }

  source_details {
    source_id   = var.image_ocid
    source_type = "image"
  }

  create_vnic_details {
    subnet_id = var.subnet_id
    assign_public_ip = true
  }

  metadata = {
    ssh_authorized_keys = var.ssh_key
  }
}

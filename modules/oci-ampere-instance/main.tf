#modules/oci-ampere-instance/main.tf

resource "oci_core_instance" "ampere_instance" {
  count                = 2
  availability_domain  = var.availability_domain
  compartment_id       = var.compartment_id
  shape                = "VM.Standard.A1.Flex"
  display_name         = "ampere-instance-${count.index + 1}"
  is_pv_encryption_in_transit_enabled = true
  
  shape_config {
    memory_in_gbs = 12
    ocpus         = 2
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
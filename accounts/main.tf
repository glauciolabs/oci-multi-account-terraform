# accounts/main.tf

terraform {

  # Backend OCI nativo
  backend "oci" {
    key = "terraform.tfstate"
  }
}

provider "oci" {
  region           = var.region
  tenancy_ocid     = var.tenancy_ocid
  user_ocid        = var.user_ocid
  fingerprint      = var.fingerprint
  private_key_path = var.private_key_path
}

module "oci_network" {
  source         = "../modules/oci-network"
  prefix         = var.prefix
  compartment_id = var.compartment_ocid
  vcn_cidr       = var.vcn_cidr
  subnet_cidr    = var.subnet_cidr
}

module "oci_ampere_instance" {
  source              = "../modules/oci-ampere-instance"
  compartment_id      = var.compartment_ocid
  availability_domain = var.availability_domain
  subnet_id           = module.oci_network.subnet_id
  image_ocid          = var.image_ocid
  ssh_key             = var.ssh_key
}

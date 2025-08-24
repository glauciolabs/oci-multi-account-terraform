# accounts/main.tf

terraform {
  required_version = "~> 1.13.0"

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

data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

locals {
  cloud_init_script = base64encode(templatefile("${path.module}/cloud-init.tftpl", {
    telegram_bot_token       = var.telegram_bot_token
    telegram_chat_id         = var.telegram_chat_id
    cf_warp_connector_secret = var.cf_warp_connector_secret
    # Dados do usuário opcional
    default_user_name        = try(var.default_user.name, "")
    default_user_groups      = try(var.default_user.groups, [])
    default_user_sudo        = try(var.default_user.sudo, "")
    default_user_ssh_key     = var.default_user_ssh_key
  }))
}

module "oci_network" {
  source = "../modules/oci-network"
  compartment_id = var.compartment_ocid
  prefix         = var.prefix
  vcn_cidr       = var.vcn_cidr

  create_public_subnet  = var.create_nlb || var.assign_public_ip
  public_subnet_cidr    = var.public_subnet_cidr

  create_private_subnet = var.create_nlb || !var.assign_public_ip
  private_subnet_cidr   = var.subnet_cidr

  nlb_listener_port = var.create_nlb ? var.nlb_listener_port : null
}

module "oci_ampere_instance" {
  source                  = "../modules/oci-ampere-instance"
  subnet_id               = module.oci_network.instance_subnet_id
  assign_public_ip        = var.create_nlb ? false : var.assign_public_ip
  compartment_id          = var.compartment_ocid
  availability_domain     = data.oci_identity_availability_domains.ads.availability_domains[var.ad_number - 1].name
  image_ocid              = var.image_ocid
  ssh_key                 = var.ssh_key
  instance_count          = var.instance_count
  instance_shape          = var.instance_shape
  instance_memory_gb      = var.instance_memory_gb
  instance_ocpus          = var.instance_ocpus
  instance_prefix         = var.prefix
  boot_volume_size_in_gbs = var.boot_volume_size_in_gbs
  user_data               = local.cloud_init_script
}

module "shared_volumes" {
  source              = "../modules/oci-shared-volumes"
  compartment_id      = var.compartment_ocid
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[var.ad_number - 1].name
  shared_volumes      = var.shared_volumes_config
}

locals {
  instance_ids = module.oci_ampere_instance.instance_ids
  volume_attachments = flatten([
    for instance_id in local.instance_ids : [
      for volume_key, volume in module.shared_volumes.volumes : {
        instance_id = instance_id
        volume_id   = volume.id
        volume_key  = volume_key
      }
    ]
  ])
}

resource "oci_core_volume_attachment" "shared_attachment" {
  count = length(local.volume_attachments)

  attachment_type = "iscsi"
  is_shareable    = true
  instance_id     = local.volume_attachments[count.index].instance_id
  volume_id       = local.volume_attachments[count.index].volume_id
  device          = local.volume_attachments[count.index].volume_key == "database_storage" ? "/dev/oracleoci/oraclevdb" : "/dev/oracleoci/oraclevdc"
}

module "oci_nlb" {
  count  = var.create_nlb ? 1 : 0
  source = "../modules/oci-nlb"
  subnet_id            = module.oci_network.nlb_subnet_id
  compartment_id       = var.compartment_ocid
  display_name_prefix  = var.prefix
  listener_port        = var.nlb_listener_port
  health_check_port    = var.nlb_health_check_port
  backend_instance_map = module.oci_ampere_instance.instance_ids_map
}
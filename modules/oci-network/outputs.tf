#modules/oci-network/outputs.tf

output "vcn_id" {
  value = oci_core_vcn.vcn.id
}

output "instance_subnet_id" {
  description = "The ID of the subnet where instances should be placed."
  value       = var.create_private_subnet ? oci_core_subnet.private_subnet[0].id : oci_core_subnet.public_subnet[0].id
}

output "nlb_subnet_id" {
  description = "The ID of the public subnet where the NLB should be placed."
  value       = var.create_public_subnet ? oci_core_subnet.public_subnet[0].id : null
}

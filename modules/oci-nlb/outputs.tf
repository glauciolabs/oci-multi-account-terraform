# modules/oci-nlb/outputs.tf

output "nlb_id" {
  description = "The OCID of the Network Load Balancer."
  value       = oci_network_load_balancer_network_load_balancer.nlb.id
}

output "nlb_ip_address" {
  description = "The public IP address of the Network Load Balancer."
  value       = oci_network_load_balancer_network_load_balancer.nlb.ip_addresses[0].ip_address
}

# modules/oci-ampere-instance/outputs.tf

output "instances_details" {
  description = "Detailed information for each created instance."
  value = [
    for instance in oci_core_instance.ampere_instance : {
      id           = instance.id
      display_name = instance.display_name
      public_ip    = instance.public_ip
      private_ip   = instance.private_ip
      shape        = instance.shape
      region       = instance.region
    }
  ]
}
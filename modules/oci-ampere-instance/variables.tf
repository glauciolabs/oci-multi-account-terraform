#modules/oci-ampere-instance/variables.tf

variable "compartment_id" {
  type        = string
  description = "ocid compartiment"
}

variable "availability_domain" {
  type        = string
  description = "availability domain"
}

variable "subnet_id" {
  type        = string
  description = "subnet id"
}

variable "image_ocid" {
  type        = string
  description = "image ocid"
}

variable "ssh_key" {
  type        = string
  description = "ssh public key"
}
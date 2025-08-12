# modules/oci-network/variables.tf

variable "compartment_id" {
  type        = string
  description = "compartment ocid"
}

variable "vcn_cidr" {
  type        = string
  description = "vcn cidr block"
}

variable "subnet_cidr" {
  type        = string
  description = "subnet cidr block"
}

variable "prefix" {
  type        = string
  description = "name prefix"
}
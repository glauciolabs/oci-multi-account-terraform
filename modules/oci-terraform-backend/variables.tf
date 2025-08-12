
#modules/oci-terraform-backend/variables.tf

variable "compartment_id" {
  type        = string
  description = "compartment ocid"
}

variable "bucket_name" {
  type        = string
  description = "bucket name"
}

variable "namespace" {
  type        = string
  description = "bucket namespace"
}
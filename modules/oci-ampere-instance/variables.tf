# modules/oci-ampere-instance/variables.tf

variable "compartment_id" {
  type        = string
  description = "OCID compartment"
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

variable "instance_count" {
  type        = number
  description = "number of instances to create"
  default     = 2
}

variable "instance_shape" {
  type        = string
  description = "instance shape"
  default     = "VM.Standard.A1.Flex"
}

variable "instance_memory_gb" {
  type        = number
  description = "memory in GB for each instance"
  default     = 12
}

variable "instance_ocpus" {
  type        = number
  description = "number of OCPUs for each instance"
  default     = 2
}

variable "instance_prefix" {
  type        = string
  description = "prefix for instance names"
  default     = "instance"
}

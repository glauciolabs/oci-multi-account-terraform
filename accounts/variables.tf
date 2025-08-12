# accounts/account1/variables.tf

variable "compartment_ocid" {
  type        = string
  description = "ocid compartiment"
}

variable "availability_domain" {
  type        = string
  description = "availability domain"
}

variable "image_ocid" {
  type        = string
  description = "image ocid"
  default     = "ocid1.image.oc1.sa-saopaulo-1.aaaaaaaath3bwke2i3zu3sgxrgnsboacjihmylxbuogivbgma476pzykarpa"
}

variable "ssh_key" {
  type        = string
  description = "ssh public key"
}

variable "region" {
  type        = string
  description = "oci region"
}

variable "prefix" {
  type        = string
  description = "name prefix"
}

variable "vcn_cidr" {
  type        = string
  description = "vcn cidr block"
  default     = "10.10.0.0/16"
}

variable "subnet_cidr" {
  type        = string
  description = "subnet cidr block"
  default     = "10.10.1.0/24"
}

# Variáveis de autenticação OCI
variable "tenancy_ocid" {
  type        = string
  description = "OCI tenancy OCID"
}

variable "user_ocid" {
  type        = string
  description = "OCI user OCID"
}

variable "fingerprint" {
  type        = string
  description = "OCI API key fingerprint"
}

variable "private_key_path" {
  type        = string
  description = "Path to OCI API private key"
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
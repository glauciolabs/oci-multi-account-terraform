# modules/oci-network/variables.tf

variable "compartment_id" {
  type        = string
  description = "compartment ocid"
}

variable "vcn_cidr" {
  type        = string
  description = "vcn cidr block"
}

variable "prefix" {
  type        = string
  description = "name prefix"
}

variable "create_public_subnet" {
  type        = bool
  description = "If true, a public subnet will be created."
  default     = false
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR for the public subnet. Required if create_public_subnet is true."
  default     = null
}

variable "create_private_subnet" {
  type        = bool
  description = "If true, a private subnet will be created."
  default     = false
}

variable "private_subnet_cidr" {
  type        = string
  description = "CIDR for the private subnet. Required if create_private_subnet is true."
  default     = null
}

variable "create_nlb" {
  type        = bool
  description = "Whether to create NLB-specific security rules"
  default     = false
}

variable "nlb_listener_port" {
  type        = number
  description = "NLB listener port"
  default     = null
}

variable "nlb_health_check_port" {
  type        = number
  description = "NLB health check port"
  default     = null
}

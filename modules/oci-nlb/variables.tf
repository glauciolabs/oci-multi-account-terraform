# modules/oci-nlb/variables.tf

variable "compartment_id" {
  type        = string
  description = "The OCID of the compartment for the NLB."
}

variable "subnet_id" {
  type        = string
  description = "The OCID of the subnet to which the NLB should be attached."
}

variable "display_name_prefix" {
  type        = string
  description = "A prefix for the display names of NLB resources."
}

variable "listener_port" {
  type        = number
  description = "The port on which the NLB listener will accept traffic."
}

variable "health_check_port" {
  type        = number
  description = "The port used by the health checker to verify backend status."
  default     = 22
}

variable "backend_instance_map" {
  type        = map(string)
  description = "A map of instance OCIDs to be added to the backend set, keyed by a static identifier."
  default     = {}
}

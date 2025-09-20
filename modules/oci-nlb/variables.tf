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
}

variable "backend_instance_map" {
  type        = map(string)
  description = "A map of instance OCIDs to be added to the backend set, keyed by a static identifier."
  default     = {}
}

variable "health_check_protocol" {
  type        = string
  description = "Protocol for health check (TCP, HTTP, HTTPS)"
  default     = "TCP"
}

variable "health_check_path" {
  type        = string
  description = "Path for HTTP/HTTPS health check"
  default     = "/"
}

variable "health_check_return_code" {
  type        = number
  description = "Expected return code for HTTP/HTTPS health check"
}

variable "health_check_response_regex" {
  type        = string
  description = "Response body regex pattern"
}

variable "health_check_interval" {
  type        = number
  description = "Health check interval in milliseconds"
}

variable "health_check_timeout" {
  type        = number
  description = "Health check timeout in milliseconds"
}

variable "health_check_retries" {
  type        = number
  description = "Number of retries for failed health checks"
}

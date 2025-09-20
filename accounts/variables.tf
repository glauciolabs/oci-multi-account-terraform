# accounts/variables.tf

variable "compartment_ocid" {
  type        = string
  description = "OCI compartment OCID"
}

variable "image_ocid" {
  type        = string
  description = "Image OCID"
}

variable "ssh_key" {
  type        = string
  description = "SSH public key"
}

variable "region" {
  type        = string
  description = "OCI region"
}

variable "prefix" {
  type        = string
  description = "Resource name prefix"
}

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
  description = "API key fingerprint"
}

variable "private_key_path" {
  type        = string
  description = "Path to private key"
}

variable "instance_count" {
  type        = number
  description = "Number of instances to create"
  default     = 2
}

variable "instance_shape" {
  type        = string
  description = "Instance shape"
  default     = "VM.Standard.A1.Flex"
}

variable "instance_memory_gb" {
  type        = number
  description = "Memory in GB for each instance"
  default     = 12
}

variable "instance_ocpus" {
  type        = number
  description = "Number of OCPUs for each instance"
  default     = 2
}

variable "boot_volume_size_in_gbs" {
  type        = number
  description = "Boot volume size in GB; null to use image default"
  default     = null
}

variable "ad_number" {
  type        = number
  description = "Availability domain number (1, 2, or 3)"
  default     = 1
  nullable    = false
}

variable "vcn_cidr" {
  type        = string
  description = "VCN CIDR block"
  default     = "10.10.0.0/16"
}

variable "subnet_cidr" {
  type        = string
  description = "Subnet CIDR block"
  default     = "10.10.1.0/24"
}

variable "public_subnet_cidr" {
  type        = string
  description = "CIDR block for the public NLB subnet (if created)."
  default     = "10.10.0.0/24"
}

variable "assign_public_ip" {
  type        = bool
  description = "Controls whether to assign public IPs to instances (only if create_nlb is false)."
  default     = true
}


variable "shared_volumes_config" {
  description = "Configuration for the shared block volumes."
  type = map(object({
    display_name = string
    size_in_gbs  = number
    device       = string
  }))
  default = {
    "database_storage" = {
      display_name = "database-storage"
      size_in_gbs  = 50
      device       = "/dev/oracleoci/oraclevdb"
    },
    "file_storage" = {
      display_name = "file-storage"
      size_in_gbs  = 56
      device       = "/dev/oracleoci/oraclevdc"
    }
  }
}

variable "default_user" {
  description = "Optional. Configuration for a default user to be created on the instance."
  type = object({
    name   = string
    groups = list(string)
    sudo   = string
  })
  default = null
}

variable "default_user_ssh_key" {
  description = "The SSH public key for the default user."
  type        = string
  sensitive   = true
  default     = ""
}

variable "telegram_bot_token" {
  type        = string
  description = "Telegram Bot Token for notifications."
  default     = ""
  sensitive   = true
}

variable "telegram_chat_id" {
  type        = string
  description = "Telegram Chat ID for notifications."
  sensitive   = true
}

variable "cf_warp_connector_secret" {
  description = "The secret token for the Cloudflare WARP connector."
  type        = string
  sensitive   = true
}

variable "create_nlb" {
  type        = bool
  description = "If true, a Network Load Balancer will be created for the instances."
}

variable "nlb_listener_port" {
  type        = number
  description = "The port for the NLB listener."
}

variable "nlb_health_check_port" {
  type        = number
  description = "The port for the NLB health check."
}

variable "nlb_health_check_protocol" {
  type        = string
  description = "Protocol for NLB health check (TCP, HTTP, HTTPS)"
}

variable "nlb_health_check_path" {
  type        = string
  description = "Path for HTTP/HTTPS health check"
}

variable "nlb_health_check_return_code" {
  type        = number
  description = "Expected return code for HTTP/HTTPS health check"
}

variable "nlb_health_check_response_regex" {
  type        = string
  description = "Response body regex for HTTP/HTTPS health check"
}

variable "nlb_health_check_interval" {
  type        = number
  description = "Health check interval in milliseconds"
}

variable "nlb_health_check_timeout" {
  type        = number
  description = "Health check timeout in milliseconds"
}

variable "nlb_health_check_retries" {
  type        = number
  description = "Number of health check retries"
}

variable "controller_public_ip" {
  type        = string
  description = "aviatrix controller public ip address(required)"
}

variable "controller_private_ip" {
  type        = string
  description = "aviatrix controller private ip address(required)"
}

variable "controller_admin_email" {
  type        = string
  description = "aviatrix controller admin email address"
}

variable "controller_admin_password" {
  type        = string
  sensitive   = true
  description = "aviatrix controller admin password"

  validation {
    condition = (
      length(var.controller_admin_password) >= 8 &&
      var.controller_admin_password != "" &&
      regex("\\d", var.controller_admin_password) &&       # Checks for at least one number
      regex("[a-zA-Z]", var.controller_admin_password) &&  # Checks for at least one letter
      regex("[^a-zA-Z0-9]", var.controller_admin_password) # Checks for at least one symbol
    )
    error_message = "Controller password must be at least 8 characters long and contain at least one letter, one number, and one symbol."
  }
}

variable "customer_id" {
  type        = string
  description = "aviatrix customer license id"
}

variable "controller_version" {
  type        = string
  description = "Aviatrix Controller version"
  default     = "latest"
}

variable "wait_for_setup_duration" {
  type        = string
  description = "Duration to wait for controller setup to complete"
  default     = "10m"
}

# terraform-docs-ignore
variable "destroy_url" {
  type        = string
  description = "Dummy URL used by terracurl during destroy operations."
  default     = "https://checkip.amazonaws.com"
}

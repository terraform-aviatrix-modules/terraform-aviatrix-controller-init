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

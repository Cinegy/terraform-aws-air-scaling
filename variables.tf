variable "domain_name" {
    description = "Active Directory fully-qualified domain name"
    default     = "ad.cinegy.local"
    type        = string
}

variable "domain_admin_password" {
    description = "Domain admin password - sensitive value, recommended to be passed in via environment variables"
    type        = string
}

variable "air_vm_count" {
    description = "Number of Air Virtual Machines to create"
    default = 1
}

variable "engine_count" {
    description = "Number of Air engines to run per VM"
    default = 16
}

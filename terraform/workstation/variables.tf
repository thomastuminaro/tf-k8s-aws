variable "common_tags" {
  type = object({
    Project = string
    Owner = string 
  })

  default = {
    Owner = "Thomas Tuminaro"
    Project = "tf-k8s-aws"
  }
}

variable "workstation_config" {
  type = object({
    workstation_name = string
    workstation_type = string
    workstation_storage = number
    workstation_ip = string
  })

  default = {
    workstation_name = "workstation"
    workstation_type = "t3.micro"
    workstation_storage = 30
    workstation_ip = "10.0.14.10"
  }

  validation {
    condition = var.workstation_config.workstation_type == "t3.micro" || var.workstation_config.workstation_type == "t3.small"
    error_message = "Currently supported EC2 instance types : t3.micro or t3.small."
  }

  validation {
    condition = var.workstation_config.workstation_storage >= 20 && var.workstation_config.workstation_storage <= 40
    error_message = "Currently supporting workstation storage between 20 and 40 Gb included."
  }

  validation {
    condition = can(regex("^10.0.14.", var.workstation_config.workstation_ip))
    error_message = "Workstation IP must be on subnet 10.0.14.0/24."
  }

  validation {
    condition = can(cidrnetmask("${var.workstation_config.workstation_ip}/24"))
    error_message = "Workstation IP must be a valid IP."
  }
}
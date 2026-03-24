variable "common_tags" {
  type = object({
    Project = string
    Owner = string 
  })
}

variable "worker_config" {
  type = object({
    worker_name = string
    worker_type = string
    worker_storage = number
    worker_ip = string
  })

  default = {
    worker_name = "worker"
    worker_type = "t3.small"
    worker_storage = 30
    worker_ip = "10.0.13.10"
  }

/*    validation {
    condition = var.worker_config.worker_type == "t2.small" || var.worker_config.worker_type == "t3.small"
    error_message = "Currently supported EC2 instance types : t2.small or t3.small."
  }

  validation {
    condition = var.worker_config.worker_storage >= 30 && var.worker_config.worker_storage <= 40
    error_message = "Currently supporting worker storage between 30 and 40 Gb included."
  }

  validation {
    condition = length(regex("^10.0.13.", var.worker_config.worker_ip)) == 1 
    error_message = "worker IP must be on subnet 10.0.13.0/24."
  }

  validation {
    condition = can(cidrnetmask("${var.worker_config.worker_ip}/24"))
    error_message = "worker IP must be a valid IP."
  } */
}

variable "cp_config_common" {
  type = object({
    cp_type = string
    cp_storage = number
  })

  default = {
    cp_type = "t3.small"
    cp_storage = 30
  }

  validation {
    condition = var.cp_config_common.cp_type == "t3.small" 
    error_message = "Currently supported EC2 instance types : t3.small."
  }

  validation {
    condition = var.cp_config_common.cp_storage >= 30 && var.cp_config_common.cp_storage <= 40
    error_message = "Currently supporting controlplane storage between 30 and 40 Gb included."
  }
}

variable "cp_config" {
  type = map(object({
    cp_ip = string
  }))

/*   validation {
    condition = alltrue([for cpip in [for ip in var.cp_config : ip] : length(regex("^10.0.1[012].", cpip)) == 1]) 
    error_message = "controlplane IP must be on subnet 10.0.10.0/24 or 10.0.11.0/24 or 10.0.12.0/24."
  }

  validation {
    condition = can(cidrnetmask("${var.cp_config.cp_ip}/24"))
    error_message = "controlplane IP must be a valid IP."
  }

  validation {
    condition = length([for k in keys(var.cp_config) : k]) == 3
    error_message = "You must configure exactly 3 controlplane instances."
  } */
}
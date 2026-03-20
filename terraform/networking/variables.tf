variable "common_tags" {
  type = object({
    Project = string
    Owner = string 
  })
}

variable "vpc" {
  type = object({
    vpc_name = string
    vpc_cidr = string 
  })

  default = {
    vpc_name = "kubernetes"
    vpc_cidr = "10.0.0.0/16"
  }

  validation {
    condition = can(cidrnetmask(var.vpc.vpc_cidr))
    error_message = "Make sure your VPC CIDR is valid."
  }
}

variable "kubernetes_cp_subnets" {
  type = map(object({
    kube_cp_sub_cidr = string
  }))

  validation {
    condition = length([for sub in keys(var.kubernetes_cp_subnets) : sub]) == 3
    error_message = "You must configure 3 subnets for controlplanes."
  }

  validation {
    condition = alltrue([ for sub in var.kubernetes_cp_subnets : can(cidrnetmask(sub.kube_cp_sub_cidr)) ])
    error_message = "One of your kubernetes control plane subnet does not have a valid CIDR."
  }
}
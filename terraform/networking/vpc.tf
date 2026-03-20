# Main VPC configuration 

resource "aws_vpc" "main" {
  cidr_block = var.vpc.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = merge(var.common_tags, {
    Name = "${var.vpc.vpc_name}"
  })
}

# Private subnets configuration for kubernetes controlplane 

# Grabbing available AZs

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "kubecp" {
  for_each = var.kubernetes_cp_subnets
  vpc_id = aws_vpc.main.id
  cidr_block = each.value.kube_cp_sub_cidr
  availability_zone = data.aws_availability_zones.available.names[index([for sub in keys(var.kubernetes_cp_subnets) : sub], each.key) % length(data.aws_availability_zones.available.names)]

  tags = merge(var.common_tags, {
    Name = "${each.key}"
  })
}


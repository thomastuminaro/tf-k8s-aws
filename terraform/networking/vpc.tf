##########################################################################################################################################################
#                                                                                                                                                        #
#                                                                                                                                                        #
#                                                                       MAIN VPC                                                                         #
#                                                                                                                                                        #
#                                                                                                                                                        #
##########################################################################################################################################################

resource "aws_vpc" "main" {
  cidr_block = var.vpc.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support = true

  tags = merge(var.common_tags, {
    Name = "${var.vpc.vpc_name}"
  })
}

##########################################################################################################################################################
#                                                                                                                                                        #
#                                                                                                                                                        #
#                                                                      SUBNETS                                                                           #
#                                                                                                                                                        #
#                                                                                                                                                        #
##########################################################################################################################################################

##########################################################################################################################################################
# Private subnets configuration for kubernetes controlplane                                                                              
# One subnet on each AZ 
##########################################################################################################################################################

# Grabbing available AZs

data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_subnet" "cp" {
  for_each = var.kubernetes_cp_subnets
  vpc_id = aws_vpc.main.id
  cidr_block = each.value.kube_cp_sub_cidr
  map_public_ip_on_launch = false
  availability_zone = data.aws_availability_zones.available.names[index([for sub in keys(var.kubernetes_cp_subnets) : sub], each.key) % length(data.aws_availability_zones.available.names)]

  tags = merge(var.common_tags, {
    Name = "${each.key}"
  })
}

##########################################################################################################################################################
# Private subnet for kubernetes worker nodes
# One subnet only on any AZ - for dev only 
##########################################################################################################################################################

resource "aws_subnet" "worker" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.kubernetes_wk_subnet
  map_public_ip_on_launch = false

  tags = merge(var.common_tags, {
    Name = "workers"
  })
}

##########################################################################################################################################################
# Public subnet for workstation 
# One subnet only on any AZ - for dev only 
##########################################################################################################################################################

resource "aws_subnet" "workstation" {
  vpc_id = aws_vpc.main.id
  cidr_block = var.workstation_subnet
  map_public_ip_on_launch = true

  tags = merge(var.common_tags, {
    Name = "workstation"
  })
}

##########################################################################################################################################################
#                                                                                                                                                        #
#                                                                                                                                                        #
#                                                                    CONNECTIVITY                                                                        #
#                                                                                                                                                        #
#                                                                                                                                                        #
##########################################################################################################################################################


##########################################################################################################################################################
# Internet gateway to be able tor each public network
##########################################################################################################################################################

resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.main.id

  tags = merge(var.common_tags, {
    Name = "public-gw"
  })
}

##########################################################################################################################################################
# NAT gateway for cluster nodes in private network to access public registries 
##########################################################################################################################################################

resource "aws_nat_gateway" "nat" {
  vpc_id = aws_vpc.main.id
  availability_mode = "regional" # NAT gw needs to be available for all private subnets which are split across AZs
  
  tags = merge(var.common_tags, {
    Name = "nat-gw"
  })
}

##########################################################################################################################################################
# Configuring route tables for the private subnets 
##########################################################################################################################################################

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat.id
  }

  tags = merge(var.common_tags, {
    Name = "private-subs-routing"
  })
}

resource "aws_route_table_association" "private-cp" {
  for_each = aws_subnet.cp
  subnet_id = each.value.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private-wk" {
  subnet_id = aws_subnet.worker.id
  route_table_id = aws_route_table.private.id
}

##########################################################################################################################################################
# Configuring route tables for the public subnet 
##########################################################################################################################################################

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public.id

  }

  tags = merge(var.common_tags, {
    Name = "public-subs-routing"
  })
}

resource "aws_route_table_association" "workstation" {
  subnet_id = aws_subnet.workstation.id
  route_table_id = aws_route_table.public.id
}

##########################################################################################################################################################
#                                                                                                                                                        #
#                                                                                                                                                        #
#                                                                   SECURITY GROUPS                                                                      #
#                                                                                                                                                        #
#                                                                                                                                                        #
##########################################################################################################################################################

##########################################################################################################################################################
# Control plane config
# Allow access from workstation group 6443 + 22 /  worker group all traffic
# Allow outbound to everywhere to pull images
##########################################################################################################################################################

resource "aws_security_group" "cp" {
  name = "controlplane-sg"
  description = "Allows controlplane communications."
  vpc_id = aws_vpc.main.id
  
  tags = merge(var.common_tags, {
    Name = "controlplane-sg"
  })
}

resource "aws_vpc_security_group_egress_rule" "allow_egress_all_cp" {
  security_group_id = aws_security_group.cp.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_workstation_cp" {
  security_group_id = aws_security_group.cp.id
  referenced_security_group_id = aws_security_group.workstation.id
  ip_protocol = "tcp"
  from_port = 22
  to_port = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_kube_from_workstation_cp" {
  security_group_id = aws_security_group.cp.id
  referenced_security_group_id = aws_security_group.workstation.id
  ip_protocol = "tcp"
  from_port = 6443
  to_port = 6443
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_from_workers_cp" {
  security_group_id = aws_security_group.cp.id
  referenced_security_group_id = aws_security_group.wk.id
  ip_protocol = -1
}

resource "aws_vpc_security_group_egress_rule" "allow_all_to_workers_cp" {
  security_group_id = aws_security_group.cp.id
  referenced_security_group_id = aws_security_group.wk.id
  ip_protocol = -1
}

##########################################################################################################################################################
# Worker config
# Allow access from workstation group 22 /  controlplane group all traffic
# Allow outbound to everywhere to pull images
##########################################################################################################################################################

resource "aws_security_group" "wk" {
  name = "worker-sg"
  description = "Allows worker communications."
  vpc_id = aws_vpc.main.id
  
  tags = merge(var.common_tags, {
    Name = "worker-sg"
  })
}

resource "aws_vpc_security_group_egress_rule" "allow_egress_all_wk" {
  security_group_id = aws_security_group.wk.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_workstation_wk" {
  security_group_id = aws_security_group.wk.id
  referenced_security_group_id = aws_security_group.workstation.id
  ip_protocol = "tcp"
  from_port = 22
  to_port = 22
}

resource "aws_vpc_security_group_ingress_rule" "allow_all_from_cp_wk" {
  security_group_id = aws_security_group.cp.id
  referenced_security_group_id = aws_security_group.cp.id
  ip_protocol = -1
}

resource "aws_vpc_security_group_egress_rule" "allow_all_to_cp_wk" {
  security_group_id = aws_security_group.cp.id
  referenced_security_group_id = aws_security_group.cp.id
  ip_protocol = -1
}

##########################################################################################################################################################
# Workstation config
# Allow access to worker/cp group 22 /  controlplane group 6443
# Allow outbound to everywhere everywhere
# Allow inbound from 88.162.198.72 (own IP) SSH
##########################################################################################################################################################

resource "aws_security_group" "workstation" {
  name = "workstation-sg"
  description = "Allows workerstation communications."
  vpc_id = aws_vpc.main.id
  
  tags = merge(var.common_tags, {
    Name = "workstation-sg"
  })
}

resource "aws_vpc_security_group_egress_rule" "allow_egress_all_workstation" {
  security_group_id = aws_security_group.workstation.id
  cidr_ipv4 = "0.0.0.0/0"
  ip_protocol = -1
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh_from_mac_workstation" {
  security_group_id = aws_security_group.workstation.id
  cidr_ipv4 = "88.162.198.72/32"
  ip_protocol = "tcp"
  from_port = 22
  to_port = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_kube_to_cp_workstation" {
  security_group_id = aws_security_group.workstation.id
  referenced_security_group_id = aws_security_group.cp.id
  ip_protocol = "tcp"
  from_port = 6443
  to_port = 6443
}

resource "aws_vpc_security_group_egress_rule" "allow_ssh_to_cp_workstation" {
  security_group_id = aws_security_group.workstation.id
  referenced_security_group_id = aws_security_group.cp.id
  ip_protocol = "tcp"
  from_port = 22
  to_port = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_ssh_to_wk_workstation" {
  security_group_id = aws_security_group.workstation.id
  referenced_security_group_id = aws_security_group.wk.id
  ip_protocol = "tcp"
  from_port = 22
  to_port = 22
}
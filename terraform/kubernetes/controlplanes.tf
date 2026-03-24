##########################################################################################################################################################
#                                                                                                                                                        #
#                                                                                                                                                        #
#                                                                        EC2                                                                             #
#                                                                                                                                                        #
#                                                                                                                                                        #
##########################################################################################################################################################

locals {
  #cp_subnets_expr = [for k in keys(data.terraform_remote_state.networking.outputs["kube_cp_sub_ids"]) : split(".", k)[2]]
  instance_sub_nic = {for k, v in var.cp_config : k => {
    cp_ip = v["cp_ip"]
    sub_id = [for cidr,sub_id in data.terraform_remote_state.networking.outputs["kube_cp_sub_ids"] : sub_id if cidrhost(cidr, split(".", v["cp_ip"])[3]) == v["cp_ip"]][0]
  }}
}

output "test3" {
    value = local.instance_sub_nic
}

/* resource "aws_network_interface" "controlplane" {
  for_each = var.cp_config
  subnet_id = "" #pending
  private_ip = each.value.cp_ip

  tags = merge(common_tags, {
    Name = "${each.key}-primary-nic"
  })
} */
/*
1 : 
name : IP
name : IP
name : IP

2:
sub_cidr : sub_id
sub_cidr : sub_id
sub_cidr : sub id 

Need :
name : {
  ip = ip
  sub_id = id 
}
*/
##########################################################################################################################################################
#                                                                                                                                                        #
#                                                                                                                                                        #
#                                                                        EC2                                                                             #
#                                                                                                                                                        #
#                                                                                                                                                        #
##########################################################################################################################################################

resource "aws_network_interface" "controlplane" {
  for_each = local.instance_sub_nic
  subnet_id = each.value.sub_id
  private_ip = each.value.cp_ip
  security_groups = [data.terraform_remote_state.networking.outputs["sg_cp_id"]]

  tags = merge(var.common_tags, {
    Name = "${each.key}-primary-nic"
  })
}  

resource "aws_instance" "cp" {
  for_each = local.instance_sub_nic
  ami = local.ami_ubuntu
  instance_type = var.cp_config_common.cp_type

  root_block_device {
    delete_on_termination = true
    volume_size = var.cp_config_common.cp_storage
    volume_type = "gp3"
  }  

  primary_network_interface {
    network_interface_id = aws_network_interface.controlplane[each.key].id
  }

  tags = merge(var.common_tags, {
    Name = "${each.key}"
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [ tags ]
  }
} 

##########################################################################################################################################################
#                                                                                                                                                        #
#                                                                                                                                                        #
#                                                                        ELB                                                                             #
#                                                                                                                                                        #
#                                                                                                                                                        #
##########################################################################################################################################################

# aws_lb, aws_lb_listner, aws_lb_target_group, aws_lb_listener_rule, aws_lb_target_group_attachment

resource "aws_lb" "cp" {
  name = var.lb_config.lb_name
  internal = true
  load_balancer_type = var.lb_config.lb_type

  subnets = [for sub in values(data.terraform_remote_state.networking.outputs["kube_cp_sub_ids"]) : sub] 

  tags = merge(var.common_tags, {
    Name = "${var.lb_config.lb_name}"
  })  
}

resource "aws_lb_listener" "cp" {
  load_balancer_arn = aws_lb.cp.arn
  port = "6443"
  protocol = "TCP"

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.cp.arn
  }
}

resource "aws_lb_target_group" "cp" {
  name = "${var.lb_config.lb_name}-tg"
  port = 6443
  protocol = "TCP"
  vpc_id = data.terraform_remote_state.networking.outputs["vpc_id"]
}

resource "aws_lb_target_group_attachment" "cp" {
  for_each = var.cp_config
  target_group_arn = aws_lb_target_group.cp.arn
  target_id = aws_instance.cp[each.key].id
  port = 6443
}
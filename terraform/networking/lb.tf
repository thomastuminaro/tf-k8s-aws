##########################################################################################################################################################
#                                                                                                                                                        #
#                                                                                                                                                        #
#                                                                  K8S CONTROL PLANE LB                                                                  #
#                                                                                                                                                        #
#                                                                                                                                                        #
##########################################################################################################################################################

resource "aws_lb" "cp" {
  name = var.lb_config.lb_name
  internal = true
  load_balancer_type = var.lb_config.lb_type
  security_groups = [ aws_security_group.lb.id ]

  #  { for sub in aws_subnet.cp : sub.cidr_block => sub.id }
  subnets = [ for sub in aws_subnet.cp : sub.id ] 

  tags = merge(var.common_tags, {
    Name = "${var.lb_config.lb_name}"
  })  
}
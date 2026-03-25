##########################################################################################################################################################
#                                                                                                                                                        #
#                                                                                                                                                        #
#                                                                        EC2                                                                             #
#                                                                                                                                                        #
#                                                                                                                                                        #
##########################################################################################################################################################

resource "aws_network_interface" "worker" {
  subnet_id = data.terraform_remote_state.networking.outputs["kube_wk_sub_id"]
  private_ip = var.worker_config.worker_ip
  security_groups = [data.terraform_remote_state.networking.outputs["sg_wk_id"]]

  tags = merge(var.common_tags, {
    Name = "worker-primary-nic"
  })
}

resource "aws_instance" "worker" {
  ami = local.ami_ubuntu
  instance_type = var.worker_config.worker_type
  
  primary_network_interface {
    network_interface_id = aws_network_interface.worker.id
  }

  root_block_device {
    delete_on_termination = true
    volume_size = var.worker_config.worker_storage
    volume_type = "gp3"
  }
  
  tags = merge(var.common_tags, {
    Name = "worker"
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [ tags ]
  }
}
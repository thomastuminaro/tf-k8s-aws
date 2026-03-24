##########################################################################################################################################################
#                                                                                                                                                        #
#                                                                                                                                                        #
#                                                                   NETWORKING DATA                                                                      #
#                                                                                                                                                        #
#                                                                                                                                                        #
##########################################################################################################################################################

data "terraform_remote_state" "vpc" {
  backend = "s3"

  config = {
    bucket = "aws-remote-backend-tf"
    key = "networking/terraform.tfstate"
    region = "eu-west-3"
  }
}

##########################################################################################################################################################
#                                                                                                                                                        #
#                                                                                                                                                        #
#                                                                        EC2                                                                             #
#                                                                                                                                                        #
#                                                                                                                                                        #
##########################################################################################################################################################

resource "aws_network_interface" "workstation" {
  subnet_id = data.terraform_remote_state.vpc.outputs["workstation_sub_id"]
  private_ip = [var.workstation_config.workstation_ip]

  tags = merge(var.common_tags, {
    Name = "workstation_primary_nic"
  })
}

resource "aws_instance" "workstation" {
  instance_type = var.workstation_config.workstation_type
  ami = local.ami_ubuntu

  primary_network_interface {
    network_interface_id = aws_network_interface.workstation.id
  }  

  vpc_security_group_ids = [data.terraform_remote_state.vpc.outputs["sg_workstation_id"]]

  root_block_device {
    delete_on_termination = true
    volume_size = var.workstation_config.workstation_storage
    volume_type = "gp3"
  }

  tags = merge(var.common_tags, {
    Name = "workstation"
  })

  lifecycle {
    create_before_destroy = true
    ignore_changes = [ tags ]
  }
}
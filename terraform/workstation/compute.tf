##########################################################################################################################################################
#                                                                                                                                                        #
#                                                                                                                                                        #
#                                                                        EC2                                                                             #
#                                                                                                                                                        #
#                                                                                                                                                        #
##########################################################################################################################################################

resource "aws_network_interface" "workstation" {
  subnet_id = data.terraform_remote_state.vpc.outputs["workstation_sub_id"]
  private_ip = var.workstation_config.workstation_ip
  security_groups = [data.terraform_remote_state.vpc.outputs["sg_workstation_id"]]

  tags = merge(var.common_tags, {
    Name = "workstation_primary_nic"
  })
}

resource "aws_instance" "workstation" {
  instance_type = var.workstation_config.workstation_type
  ami = local.ami_ubuntu
  key_name = "workstation" # for now Terraform not creating keys from scratch, using one created manually

  iam_instance_profile = aws_iam_instance_profile.workstation.name  

  user_data = templatefile("${path.module}/scripts/user_data.sh", {
    efs_dns = "blank"
  })

  primary_network_interface {
    network_interface_id = aws_network_interface.workstation.id
  }  

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

  depends_on = [ aws_network_interface.workstation, aws_s3_bucket.scripts ]
}
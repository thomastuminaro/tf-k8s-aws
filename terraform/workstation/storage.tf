##########################################################################################################################################################
# Bucket for ansible scripts
##########################################################################################################################################################

resource "aws_s3_bucket" "scripts" {
  bucket = "ansible-config-bucket-tuminaro"

  tags = merge(var.common_tags, {
    Name = "ansible-config-bucket-tuminaro"
  })
}

##########################################################################################################################################################
# Uploading files to bucket
##########################################################################################################################################################

resource "aws_s3_object" "ansible_config" {
  bucket = aws_s3_bucket.scripts.bucket
  key = "ansible-defaults.cfg"
  source = "${path.root}/files/bootstrap/ansible-defaults.cfg"
}

resource "aws_s3_object" "ansible_inventory" {
  bucket = aws_s3_bucket.scripts.bucket
  key = "inventory-defaults"
  source = "${path.root}/files/bootstrap/inventory-defaults"
}

resource "aws_s3_object" "ansible_base_playbook" {
  bucket = aws_s3_bucket.scripts.bucket
  key = "init-ssh.yaml"
  source = "${path.module}/files/bootstrap/init-ssh.yaml"
}

output "test" {
    value = "${path.root}"
}
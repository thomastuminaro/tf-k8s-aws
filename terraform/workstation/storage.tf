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
  key = "ansible.cfg"
  source = "${path.root}/files/bootstrap/ansible.cfg"
}

resource "local_file" "inventory" {
  content = templatefile("${path.module}/files/bootstrap/templates/inventory.tftpl", {
        wks = var.workers,
        cps = var.controlplanes
    })
    filename = "${path.module}/files/bootstrap/inventory"
}

resource "aws_s3_object" "ansible_inventory" {
  bucket = aws_s3_bucket.scripts.bucket
  key = "inventory-defaults"
  source = "${path.root}/files/bootstrap/inventory"
}

resource "null_resource" "deleteTemp" {
  depends_on = [ aws_s3_object.ansible_inventory ]
  provisioner "local-exec" {
    command = "rm -f ${local_file.inventory.filename}"
  }
}
/* variable "controlplanes" {
  type = list(string)
  
  default = [ "controlplane-01", "controlplane-02", "controlplane-03" ]
}

variable "workers" {
  type = list(string)

  default = [ "worker" ]
}

output "testcp" {
    value = templatefile("${path.module}/inventory.tftpl", {
        wks = var.workers,
        cps = var.controlplanes
    })
}

resource "local_file" "inventory" {
  content = templatefile("${path.module}/inventory.tftpl", {
        wks = var.workers,
        cps = var.controlplanes
    })
    filename = "${path.module}/inventory"
}

resource "aws_s3_bucket" "test" {
  bucket = "testing-templating"
}

resource "aws_s3_object" "inventory" {
  bucket = aws_s3_bucket.test.id
  key = "inventory"
  source = "${path.module}/inventory"
}

resource "null_resource" "deleteTemp" {
  depends_on = [ aws_s3_object.inventory ]
  provisioner "local-exec" {
    command = "rm -f ${local_file.inventory.filename}"
  }
} */

resource "tls_private_key" "workstation" {
  algorithm = "ED25519"
}

output "workstation-tls" {
    value = tls_private_key.workstation.public_key_openssh
}

resource "aws_secretsmanager_secret" "key" {
  name = "testkeythomas"
}

resource "aws_secretsmanager_secret_version" "key" {
  secret_id = aws_secretsmanager_secret.key.id
  secret_string = tls_private_key.workstation.public_key_openssh
}
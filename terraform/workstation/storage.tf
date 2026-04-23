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
# Uploading ansible config to bucket
##########################################################################################################################################################

resource "aws_s3_object" "ansible_config" {
  bucket = aws_s3_bucket.scripts.bucket
  key = "ansible.cfg"
  source = "${path.root}/files/bootstrap/ansible.cfg"
}
##########################################################################################################################################################
# Uploading inventory by templating (generate temp file from template, upload to s3, delete local temp file)
##########################################################################################################################################################

resource "local_file" "inventory" {
  content = templatefile("${path.module}/files/bootstrap/templates/inventory.tftpl", {
        maincp = var.controlplanes[0]
        wks = var.workers,
        cps = slice(var.controlplanes, 1, length(var.controlplanes))
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

##########################################################################################################################################################
# Uploading ansible playbooks and groupvars file
##########################################################################################################################################################

resource "aws_s3_object" "playbook_maincp" {
  bucket = aws_s3_bucket.scripts.bucket
  key = "main-cp-install.yaml"
  source = "${path.module}/files/bootstrap/main-cp-install.yaml"
}

resource "aws_s3_object" "playbook_othercp" {
  bucket = aws_s3_bucket.scripts.bucket
  key = "second-cp-install.yaml"
  source = "${path.module}/files/bootstrap/second-cp-install.yaml"
}

resource "aws_s3_object" "playbook_worker" {
  bucket = aws_s3_bucket.scripts.bucket
  key = "worker-install.yaml"
  source = "${path.module}/files/bootstrap/worker-install.yaml"
}

resource "aws_s3_object" "groupvars" {
  bucket = aws_s3_bucket.scripts.bucket
  key = "all.yaml"
  source = "${path.module}/files/bootstrap/vars_all.yaml"
}

##########################################################################################################################################################
# Uploading ansible template for main controlplane 
##########################################################################################################################################################

resource "local_file" "kubeadm_init_main" {
  content = templatefile("${path.module}/files/bootstrap/templates/kubeadm-init-main.tftpl", {
        lbendpoint = "${data.terraform_remote_state.vpc.outputs["lb_dns"]}"
    })
    filename = "${path.module}/files/bootstrap/kubeadm-init-main.j2"
}

resource "aws_s3_object" "kubeadm_init_main" {
  bucket = aws_s3_bucket.scripts.bucket
  key = "kubeadm-init-main.j2"
  source = "${path.root}/files/bootstrap/kubeadm-init-main.j2"
}

resource "null_resource" "kubeadm_init_main_delete" {
  depends_on = [ aws_s3_object.kubeadm_init_main ]
  provisioner "local-exec" {
    command = "rm -f ${local_file.kubeadm_init_main.filename}"
  }
}

##########################################################################################################################################################
# Uploading ansible template for other controlplans
##########################################################################################################################################################

resource "local_file" "kubeadm_joincp" {
  content = templatefile("${path.module}/files/bootstrap/templates/kubeadm-join-cp.tftpl", {
        lbendpoint = "${data.terraform_remote_state.vpc.outputs["lb_dns"]}"
    })
    filename = "${path.module}/files/bootstrap/kubeadm-join-cp.j2"
}

resource "aws_s3_object" "kubeadm_joincp" {
  bucket = aws_s3_bucket.scripts.bucket
  key = "kubeadm-join-cp.j2"
  source = "${path.root}/files/bootstrap/kubeadm-join-cp.j2"
}

resource "null_resource" "kubeadm_joincp_delete" {
  depends_on = [ aws_s3_object.kubeadm_joincp ]
  provisioner "local-exec" {
    command = "rm -f ${local_file.kubeadm_joincp.filename}"
  }
}

##########################################################################################################################################################
# Uploading ansible template for other controlplans
##########################################################################################################################################################

resource "local_file" "kubeadm_joinwk" {
  content = templatefile("${path.module}/files/bootstrap/templates/kubeadm-join-wk.tftpl", {
        lbendpoint = "${data.terraform_remote_state.vpc.outputs["lb_dns"]}"
    })
    filename = "${path.module}/files/bootstrap/kubeadm-join-wk.j2"
}

resource "aws_s3_object" "kubeadm_joinwk" {
  bucket = aws_s3_bucket.scripts.bucket
  key = "kubeadm-join-wk.j2"
  source = "${path.root}/files/bootstrap/kubeadm-join-wk.j2"
}

resource "null_resource" "kubeadm_joinwk_delete" {
  depends_on = [ aws_s3_object.kubeadm_joinwk ]
  provisioner "local-exec" {
    command = "rm -f ${local_file.kubeadm_joinwk.filename}"
  }
}
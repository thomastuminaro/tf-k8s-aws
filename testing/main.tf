module "networking" {
  source = "git@github.com:thomastuminaro/k8s-networking-module-tf.git?ref=0.1"

  common_tags = {
    Owner   = "Thomas Tuminaro"
    Project = "tf-k8s-aws"
  }

  kubernetes_cp_subnets = {
    "controlplane01" = {
      kube_cp_sub_cidr = "10.0.10.0/24"
    },
    "controlplane02" = {
      kube_cp_sub_cidr = "10.0.11.0/24"
    },
    "controlplane03" = {
      kube_cp_sub_cidr = "10.0.12.0/24"
    }
  }

  kubernetes_wk_subnet = "10.0.13.0/24"
  workstation_subnet   = "10.0.14.0/24"
}

module "workstation" {
  source = "git@github.com:thomastuminaro/workstation-module.git?ref=0.1"

  workstation_config = {
    workstation_name    = "workstation"
    workstation_storage = 30
    workstation_type    = "t3.micro"
    workstation_ip      = "10.0.14.10"
  }

  common_tags = {
    Owner   = "Thomas Tuminaro"
    Project = "tf-k8s-aws"
  }

  controlplanes = ["controlplane-01", "controlplane-02", "controlplane-03"]
  workers = ["worker"]

  bucket_ansible_main = "ansible-config-bucket-tuminaro"
  ansible_files = "/Users/thomastuminaro/Documents/Work/Projects/tf-k8s-aws/ansible/moduletests"
  user_data_path = "/Users/thomastuminaro/Documents/Work/Projects/tf-k8s-aws/scripts"

  lb_dns = module.networking.lb_dns

  network_config = {
    subnet = "${module.networking.workstation_sub_id}"
    security_group = "${module.networking.sg_workstation_id}"
    domain = "${module.networking.domain}"
  }
} 
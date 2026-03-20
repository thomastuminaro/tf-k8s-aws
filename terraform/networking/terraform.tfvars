common_tags = {
  Owner = "Thomas Tuminaro"
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
common_tags = {
  Owner = "Thomas Tuminaro"
  Project = "tf-k8s-aws"
}

cp_config = {
  "controlplane-01" = {
    cp_ip = "10.0.10.10"
  },
  "controlplane-02" = {
    cp_ip = "10.0.11.10"
  },
  "controlplane-03" = {
    cp_ip = "10.0.12.10"
  }
}
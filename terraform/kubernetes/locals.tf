locals {
  instance_sub_nic = {for k, v in var.cp_config : k => {
    cp_ip = v["cp_ip"]
    sub_id = [for cidr,sub_id in data.terraform_remote_state.networking.outputs["kube_cp_sub_ids"] : sub_id if cidrhost(cidr, split(".", v["cp_ip"])[3]) == v["cp_ip"]][0]
  }}
  /*
    Above gives like : 
    {
        {
            "cp_ip": "10.0.10.10",
            "sub_id": "subnet-xxxxxxx"
        },
        {
            "cp_ip": "10.0.11.10",
            "sub_id": "subnet-yyyyyyy"
        }
    }
  */

  ami_ubuntu = "ami-04c332520bd9cedb4"
}
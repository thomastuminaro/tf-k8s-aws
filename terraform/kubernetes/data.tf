data "terraform_remote_state" "networking" {
  backend = "s3"
  
  config = {
    bucket = "aws-remote-backend-tf"
    key = "networking/terraform.tfstate"
    region = "eu-west-3"
  }
}

data "terraform_remote_state" "workstation" {
  backend = "s3"
  
  config = {
    bucket = "aws-remote-backend-tf"
    key = "workstation/terraform.tfstate"
    region = "eu-west-3"
  }
}
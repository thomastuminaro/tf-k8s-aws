terraform {
  backend "s3" {
    bucket = "aws-remote-backend-tf"
    key    = "workstation/terraform.tfstate"
    region = "eu-west-3"
  }
}
terraform {
  backend "s3" {
    bucket = "aws-remote-backend-tf"
    key = "kubernetes/terraform.tfstate"
    region = "eu-west-3"
  }
}
terraform {
  backend "s3" {
    bucket = "aws-remote-backend-tf"
    key    = "networking/terraform.tfstate"
    region = "eu-west-3"
  }
}
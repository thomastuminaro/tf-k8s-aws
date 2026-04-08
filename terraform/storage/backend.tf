terraform {
  backend "s3" {
    bucket = "aws-remote-backend-tf"
    key    = "storage/terraform.tfstate"
    region = "eu-west-3"
  }
}
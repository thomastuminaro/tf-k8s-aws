terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~>6.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "2.8.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "3.2.4"
    }
    tls = {
      source = "hashicorp/tls"
      version = "4.2.1"
    }
  }
}

provider "aws" {
  region = "eu-west-3"
}

terraform {

  backend "s3" {

    bucket = "devops-fintech-tf-state"

    key = "dev/network/terraform.tfstate"

    region = "us-east-2"

  }

}


provider "aws" {

  region = "us-east-2"

}
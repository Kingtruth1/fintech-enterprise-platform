terraform {
  backend "s3" {

    bucket = "devops-fintech-tf-state"

    key = "terraform/dev/terraform.tfstate"

    region = "us-east-2"

    encrypt = true

    use_lockfile = true

  }
}
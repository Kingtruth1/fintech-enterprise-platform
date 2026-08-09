resource "aws_ecr_repository" "payment" {

  name = "payment-service"

  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {

    scan_on_push = true

  }

  encryption_configuration {

    encryption_type = "AES256"

  }

  tags = {

    Project = "FinTech"

    Environment = var.environment

  }

}
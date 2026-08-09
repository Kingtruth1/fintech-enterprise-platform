module "vpc" {

  source = "../../modules/vpc"


  environment = "dev"


  vpc_cidr = "10.0.0.0/16"


  availability_zones = [

    "us-east-2a",

    "us-east-2b"

  ]


  public_subnet_cidrs = [

    "10.0.1.0/24",

    "10.0.2.0/24"

  ]


  private_subnet_cidrs = [

    "10.0.10.0/24",

    "10.0.20.0/24"

  ]

}

module "ecr" {

  source = "../../modules/ecr"

  environment = "dev"

}
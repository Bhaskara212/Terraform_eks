module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.cluster_name}-vpc"
  cidr = var.vpc_cidr

  azs = [
    "${var.aws_region}a",
    "${var.aws_region}b",
    "${var.aws_region}c"
  ]

  public_subnets = [
    "10.64.0.0/20",
    "10.64.16.0/20",
    "10.64.32.0/20"
  ]

  private_subnets = [
    "10.64.48.0/20",
    "10.64.64.0/20",
    "10.64.80.0/20"
  ]

  enable_nat_gateway = true
  single_nat_gateway = false

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = {
    Environment = var.environment
  }
}
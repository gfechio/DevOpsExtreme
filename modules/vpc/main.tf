provider aws {}
data "aws_region" "current" {}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "default" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true

  tags = {
    Name                                        = var.default_tag,
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

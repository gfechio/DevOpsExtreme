data "aws_region" "current" {}
data "aws_availability_zones" "available" {}

variable "key_name" {
  default = "project-key"
}

variable "cluster_name" {}

variable "vpc_id" {}

variable "private_subnet_ids" { type = list(any) }

variable "public_subnet_ids" { type = list(any) }

variable "security_group" {}

variable "bucket_name" {
  default = "extreme-devops-uniq-alb-logs-bucket"
}

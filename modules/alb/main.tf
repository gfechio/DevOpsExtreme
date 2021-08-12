provider aws {}

module "alb" {
  source  = "terraform-aws-modules/alb/aws"
  version = "~> 5.0"

  name = "devops-extreme"

  load_balancer_type = "application"

  vpc_id          = var.vpc_id
  subnets         = var.public_subnet_ids
  security_groups = [var.security_group]

  target_groups = [
    {
      name_prefix      = "devops-"
      backend_protocol = "HTTP"
      backend_port     = 80
      target_type      = "instance"
    }
  ]

  http_tcp_listeners = [
    {
      port               = 80
      protocol           = "HTTP"
      target_group_index = 0
    }
  ]

  tags = {
    Environment = "workshop"
  }
}

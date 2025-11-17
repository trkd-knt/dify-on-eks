resource "aws_lb" "dify_alb" {
  name               = var.system_name

  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.dify_alb.id]
  subnets            = var.public_subnet_ids
}

resource "aws_security_group" "dify_alb" {
  name   = "${var.system_name}-alb"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = [var.vpc_cidr_block]
  }
}

module "cert" {
  count = var.use_custom_domain ? 1 : 0
  source = "./acm"

  hosted_zone_name = var.hosted_zone_name
}

resource "aws_lb_listener" "redirect" {
  count            = var.use_custom_domain ? 1 : 0

  load_balancer_arn = aws_lb.dify_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "main" {
  load_balancer_arn = aws_lb.dify_alb.arn
  port              = var.use_custom_domain ? 443 : 80
  protocol          = var.use_custom_domain ? "HTTPS" : "HTTP"
  
  ssl_policy = var.use_custom_domain ? "ELBSecurityPolicy-2016-08" : null
  certificate_arn = var.use_custom_domain ? module.cert.acm_arn : null

  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404 Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_target_group" "dify_api" {
  name     = "dify-api"

  port     = 5001
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "ip"
  health_check {
    path = "/health"
  }
}

resource "aws_lb_target_group" "dify_web" {
  name     = "dify-web"

  port     = 3000
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  target_type = "ip"
  health_check {
    path = "/apps"
  }
}

resource "aws_lb_listener_rule" "api" {
    listener_arn = aws_lb_listener.main.arn
    priority     = 10
    
    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.dify_api.arn
    }
    
    condition {
        path_pattern {
        values = [
            "/api/*",
            "/console/api/*",
            "/v1/*",
            "/files/*"
        ]
        }
    }
}

resource "aws_lb_listener_rule" "web" {
    listener_arn = aws_lb_listener.main.arn
    priority     = 20
    
    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.dify_web.arn
    }
    
    condition {
        path_pattern {
        values = [
            "/*"
        ]
        }
    }
}

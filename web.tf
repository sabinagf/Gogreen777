resource "aws_launch_template" "webtier" {
  name_prefix            = var.prefix
  image_id               = data.aws_ami.amazon-linux2.id
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.webtier.key_name
  vpc_security_group_ids = [module.web_security_group.security_group_id["web_sg"]]
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "web-instance"
    }
  }

  user_data = filebase64("${path.module}/s.sh")
}

resource "aws_key_pair" "webtier" {
  key_name   = "webtier-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}


resource "aws_lb" "webtier_alb" {
  name               = "web-lb"
  internal           = false
  load_balancer_type = "application"
  idle_timeout       = 65
  security_groups    = [module._web_security_group.security_group_id["alb_web_sg"]]
  subnets            = [aws_subnet.public_subnets["Public_Sub_WEB_1A"].id, aws_subnet.public_subnets["Public_Sub_WEB_1B"].id]

  tags = {
    Name = "webtier alb"
  }
}

resource "aws_lb_target_group" "webtier_tg" {
  name     = "webtgs"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  health_check {
    path                = "/"
    interval            = 200
    timeout             = 60
    healthy_threshold   = 5
    unhealthy_threshold = 5
    matcher             = "200" # has to be HTTP 200 or fails
  }
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 120
  }
}


resource "aws_autoscaling_group" "webtier_asg" {
  name_prefix         = var.prefix
  min_size            = 2
  max_size            = 4
  health_check_type   = "ELB"
  vpc_zone_identifier = [aws_subnet.public_subnets["Public_Sub_WEB_1A"].id, aws_subnet.public_subnets["Public_Sub_WEB_1B"].id]
  target_group_arns   = [aws_lb_target_group.webtier_tg.arn]

  launch_template {
    id      = aws_launch_template.webtier.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "webtier_asg_policy" {
  name                   = "webtier_asg_policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.webtier_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }
}

# Create a new ALB Target Group attachment
resource "aws_autoscaling_attachment" "web_attach" {
  autoscaling_group_name = aws_autoscaling_group.webtier_asg.id
  lb_target_group_arn    = aws_lb_target_group.webtier_tg.arn
}


resource "aws_lb_listener" "web_http_listener_1" {
  load_balancer_arn = aws_lb.webtier_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type = "forward"
  target_group_arn = aws_lb_target_group.webtier_tg.arn
  }
}
#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }


# # create a listener on port 443 with forward action
# resource "aws_lb_listener" "alb_https_listener" {
#   load_balancer_arn  = aws_lb.webtier_alb.
#   port               = 443
#   protocol           = "HTTPS"
#   ssl_policy         = "ELBSecurityPolicy-2016-08"
#   certificate_arn    = aws_acm_certificate.acm_certificate.arn

#   default_action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.webtier_tg.arn
#   }
# }



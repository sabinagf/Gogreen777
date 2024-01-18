resource "aws_launch_template" "apptier" {
  name_prefix            = var.prefix
  image_id               = "ami-01450e8988a4e7f44"
  instance_type          = "t2.micro"
  key_name               = aws_key_pair.apptier.key_name
  vpc_security_group_ids = [module.app_security_group.security_group_id["app_sg"]]
  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "app-instance"
    }
  }

  user_data = filebase64("${path.module}/s.sh")
}

resource "aws_key_pair" "apptier" {
  key_name   = "apptier-key"
  public_key = file("~/.ssh/id_ed25519.pub")
}

resource "aws_lb_target_group" "apptier_tg" {
  # name_prefix = var.prefix
  name     = "apptg"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.vpc.id
  health_check {
    path                = "/"
    interval            = 200
    timeout             = 60
    healthy_threshold   = 2
    unhealthy_threshold = 2
    matcher             = "200" # has to be HTTP 200 or fails
  }
  stickiness {
    type            = "lb_cookie"
    cookie_duration = 120
  }
}

resource "aws_autoscaling_group" "apptier_asg" {
  name_prefix         = var.prefix
  min_size            = 2
  max_size            = 4
  health_check_type   = "ELB"
  vpc_zone_identifier = [aws_subnet.private_subnets["Private_Sub_APP_1B"].id, aws_subnet.private_subnets["Private_Sub_APP_1A"].id]
  target_group_arns   = [aws_lb_target_group.apptier_tg.arn]

  launch_template {
    id      = aws_launch_template.apptier.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_policy" "apptier_asg_policy" {
  name                   = "application_asg_policy"
  policy_type            = "TargetTrackingScaling"
  autoscaling_group_name = aws_autoscaling_group.apptier_asg.name

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 70.0
  }
}

# Create a new  Target Group attachment
resource "aws_autoscaling_attachment" "app_attach" {
  autoscaling_group_name = aws_autoscaling_group.apptier_asg.id
  lb_target_group_arn    = aws_lb_target_group.apptier_tg.arn
}

resource "aws_lb" "apptier_alb" {
  name               = "app-lb"
  internal           = true
  load_balancer_type = "application"
  idle_timeout       = 65
  security_groups    = [module._app_security_group.security_group_id["alb_app_sg"]]
  subnets            = [aws_subnet.private_subnets["Private_Sub_APP_1B"].id, aws_subnet.private_subnets["Private_Sub_APP_1A"].id]
  tags = {
    name = "app_lb"
  }
}


resource "aws_lb_listener" "application_alb_listener_1" {
  load_balancer_arn = aws_lb.apptier_alb.arn
  port              = "8080"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.apptier_tg.arn
  }
}

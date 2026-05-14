resource "aws_security_group" "alb_sg" {
  name   = "genesis-alb-sg"
  vpc_id = var.vpc_id

  ingress {
    description = "Allow HTTP from internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "genesis-alb-sg"
    Environment = var.environment
  }
}

resource "aws_security_group" "app_sg" {
  name   = "genesis-app-sg"
  vpc_id = var.vpc_id

  ingress {
    description     = "Allow HTTP from ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "genesis-app-sg"
    Environment = var.environment
  }
}

resource "aws_iam_role" "ec2_ssm_role" {
  name = "project-genesis-ec2-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy" "ec2_ssm_policy" {
  name = "project-genesis-ssm-policy"
  role = aws_iam_role.ec2_ssm_role.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ssm:GetParameter"
      ]
      Resource = "arn:aws:ssm:*:*:parameter/project-genesis/*"
    }]
  })
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "project-genesis-ec2-profile"
  role = aws_iam_role.ec2_ssm_role.name
}

resource "aws_lb" "genesis_alb" {
  name               = "genesis-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name        = "genesis-alb"
    Environment = var.environment
  }
}

resource "aws_lb_target_group" "genesis_tg" {
  name     = "genesis-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    path                = "/health"
    port                = "80"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }

  tags = {
    Name        = "genesis-target-group"
    Environment = var.environment
  }
}

resource "aws_lb_listener" "genesis_listener" {
  load_balancer_arn = aws_lb.genesis_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.genesis_tg.arn
  }
}

resource "aws_launch_template" "genesis_lt" {
  name_prefix   = "genesis-lt-"
  image_id      = var.app_ami_id
  instance_type = var.instance_type
  key_name      = "lusine-server-pem"

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  user_data = base64encode(<<-EOF
#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -eux

echo "START USER DATA"

systemctl start docker

DB_USERNAME=$$(aws ssm get-parameter \
  --name "/project-genesis/db-username" \
  --query "Parameter.Value" \
  --output text \
  --region us-east-1)

DB_PASSWORD=$$(aws ssm get-parameter \
  --name "/project-genesis/db-password" \
  --with-decryption \
  --query "Parameter.Value" \
  --output text \
  --region us-east-1)

cd /home/ubuntu

rm -rf project-genesis
git clone https://github.com/lusinedavtyan/devops.git project-genesis

cd /home/ubuntu/project-genesis/gaming-api

cat > .env <<EOT
DATABASE_URL=postgresql://$${DB_USERNAME}:$${DB_PASSWORD}@${var.db_endpoint}/genesis_db
EOT

docker-compose down || true
docker-compose up -d --build

docker ps -a

echo "FINISHED USER DATA"
EOF
  )

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "genesis-asg-instance"
      Environment = var.environment
    }
  }

  tags = {
    Name        = "genesis-launch-template"
    Environment = var.environment
  }
}

resource "aws_autoscaling_group" "genesis_asg" {
  name             = "genesis-asg"
  min_size         = var.min_size
  max_size         = var.max_size
  desired_capacity = var.desired_capacity

  vpc_zone_identifier = var.public_subnet_ids
  target_group_arns   = [aws_lb_target_group.genesis_tg.arn]

  health_check_type         = "ELB"
  health_check_grace_period = 180

  launch_template {
    id      = aws_launch_template.genesis_lt.id
    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "genesis-asg-instance"
    propagate_at_launch = true
  }
}

resource "aws_autoscaling_policy" "genesis_cpu_scaling" {
  name                   = "genesis-cpu-target-tracking"
  autoscaling_group_name = aws_autoscaling_group.genesis_asg.name
  policy_type            = "TargetTrackingScaling"

  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }

    target_value = 50.0
  }
}

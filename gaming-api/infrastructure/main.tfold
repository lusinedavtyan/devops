terraform {
  backend "s3" {
    bucket       = "project-genesis-tf-state-aram-20260503"
    key          = "project-genesis/terraform.tfstate"
    region       = "us-east-1"
    use_lockfile = true
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

variable "db_username" {
  type    = string
  default = "genesis_user"
}

variable "db_password" {
  type      = string
  sensitive = true
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_vpc" "genesis_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "genesis-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.genesis_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "genesis-public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.genesis_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "genesis-public-subnet-2"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.genesis_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "genesis-private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.genesis_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "genesis-private-subnet-2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.genesis_vpc.id

  tags = {
    Name = "genesis-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.genesis_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "genesis-public-rt"
  }
}

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.genesis_vpc.id

  tags = {
    Name = "genesis-private-rt"
  }
}

resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_assoc_2" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "private_assoc_1" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_assoc_2" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_db_subnet_group" "genesis_db_subnet_group" {
  name = "genesis-db-subnet-group"

  subnet_ids = [
    aws_subnet.private_subnet.id,
    aws_subnet.private_subnet_2.id
  ]

  tags = {
    Name = "genesis-db-subnet-group"
  }
}

resource "aws_security_group" "alb_sg" {
  name   = "genesis-alb-sg"
  vpc_id = aws_vpc.genesis_vpc.id

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
    Name = "genesis-alb-sg"
  }
}

resource "aws_security_group" "app_sg" {
  name   = "genesis-app-sg"
  vpc_id = aws_vpc.genesis_vpc.id

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

    # For homework this is okay. In real projects, use your IP only.
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
    Name = "genesis-app-sg"
  }
}

resource "aws_security_group" "db_sg" {
  name   = "genesis-db-sg"
  vpc_id = aws_vpc.genesis_vpc.id

  ingress {
    description     = "Allow PostgreSQL from app servers only"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "genesis-db-sg"
  }
}

resource "aws_db_instance" "genesis_db" {
  identifier             = "genesis-db"
  engine                 = "postgres"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_name                = "genesis_db"
  username               = var.db_username
  password               = var.db_password
  db_subnet_group_name   = aws_db_subnet_group.genesis_db_subnet_group.name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  publicly_accessible = false
  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    Name = "genesis-rds-postgres"
  }
}

resource "aws_lb" "genesis_alb" {
  name               = "genesis-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]

  subnets = [
    aws_subnet.public_subnet.id,
    aws_subnet.public_subnet_2.id
  ]

  tags = {
    Name = "genesis-alb"
  }
}

resource "aws_lb_target_group" "genesis_tg" {
  name     = "genesis-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.genesis_vpc.id

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
    Name = "genesis-target-group"
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
  image_id      = data.aws_ami.ubuntu.id
  instance_type = "t3.micro"
  key_name      = "lusine-server-pem"

  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = base64encode(<<EOF
#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -eux

echo "START USER DATA"

apt-get update -y
DEBIAN_FRONTEND=noninteractive apt-get install -y git docker.io docker-compose

systemctl start docker
systemctl enable docker

cd /home/ubuntu

rm -rf project-genesis
git clone https://github.com/lusinedavtyan/devops.git project-genesis

cd /home/ubuntu/project-genesis/gaming-api

cat > .env <<EOT
DATABASE_URL=postgresql://${var.db_username}:${var.db_password}@${aws_db_instance.genesis_db.endpoint}/genesis_db
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
      Name = "genesis-asg-instance"
    }
  }

  tags = {
    Name = "genesis-launch-template"
  }
}

resource "aws_autoscaling_group" "genesis_asg" {
  name             = "genesis-asg"
  min_size         = 2
  max_size         = 4
  desired_capacity = 2

  vpc_zone_identifier = [
    aws_subnet.public_subnet.id,
    aws_subnet.public_subnet_2.id
  ]

  target_group_arns = [
    aws_lb_target_group.genesis_tg.arn
  ]

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

output "alb_dns_name" {
  value = aws_lb.genesis_alb.dns_name
}

output "rds_endpoint" {
  value = aws_db_instance.genesis_db.endpoint
}

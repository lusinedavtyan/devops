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

module "networking" {
  source = "./modules/networking"

  vpc_cidr             = "10.0.0.0/16"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.4.0/24"]
  private_subnet_cidrs = ["10.0.2.0/24", "10.0.3.0/24"]
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
  environment          = "production"
}

resource "aws_ssm_parameter" "db_username" {
  name  = "/project-genesis/db-username"
  type  = "String"
  value = var.db_username
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/project-genesis/db-password"
  type  = "SecureString"
  value = var.db_password
}

module "compute" {
  source = "./modules/compute"

  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  app_ami_id        = data.aws_ami.ubuntu.id
  db_endpoint       = aws_db_instance.genesis_db.endpoint
  db_username       = var.db_username
  db_password       = var.db_password
  environment       = "production"
}

resource "aws_db_subnet_group" "genesis_db_subnet_group" {
  name = "genesis-db-subnet-group"

  subnet_ids = module.networking.private_subnet_ids

  tags = {
    Name = "genesis-db-subnet-group"
  }
}

resource "aws_security_group" "db_sg" {
  name   = "genesis-db-sg"
  vpc_id = module.networking.vpc_id

  ingress {
    description     = "Allow PostgreSQL from app servers only"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [module.compute.app_sg_id]
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

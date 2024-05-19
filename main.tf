terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.0.0"
    }
  }
  required_version = "~> 1.1.5"
}

provider "aws" {
  region = var.aws_region
}

data "aws_availability_zones" "available" {}

resource "aws_vpc" "terraform_vpc" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true

  tags = {
    Name = "terraform_vpc"
  }
}

resource "aws_internet_gateway" "terraform_igw" {
  vpc_id = aws_vpc.terraform_vpc.id

  tags = {
    Name = "terraform_igw"
  }
}

resource "aws_subnet" "terraform_public_subnet" {
  count             = var.subnet_count.public
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = var.public_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "terraform_public_subnet_${count.index}"
  }
}

resource "aws_subnet" "terraform_private_subnet" {
  count             = var.subnet_count.private
  vpc_id            = aws_vpc.terraform_vpc.id
  cidr_block        = var.private_subnet_cidr_blocks[count.index]
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "terraform_private_subnet_${count.index}"
  }
}

resource "aws_route_table" "terraform_public_RT" {
  vpc_id = aws_vpc.terraform_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.terraform_igw.id
  }
}

resource "aws_route_table_association" "public" {
  count          = var.subnet_count.public
  route_table_id = aws_route_table.terraform_public_RT.id
  subnet_id      = aws_subnet.terraform_public_subnet[count.index].id
}

resource "aws_route_table" "terraform_private_RT" {
  vpc_id = aws_vpc.terraform_vpc.id
}

resource "aws_route_table_association" "private" {
  count          = var.subnet_count.private
  route_table_id = aws_route_table.terraform_private_RT.id
  subnet_id      = aws_subnet.terraform_private_subnet[count.index].id
}

resource "aws_security_group" "terraform_web_SG" {
  name        = "terraform_web_SG"
  description = "This security group for the EC2 instances"
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    description = "Rule to whitelist HTTP port for internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Rule to whitelist HTTPS port for internet"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Rule to whitelist SSH port for internet"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "terraform_web_SG"
  }
}

resource "aws_security_group" "terraform_rds_SG" {
  name        = "terraform_rds_SG"
  description = "This security group for the RDS instances"
  vpc_id      = aws_vpc.terraform_vpc.id

  ingress {
    description = "Allow MySQL traffic from the EC2 instance"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.terraform_web_SG.id]
  }

  tags = {
    Name = "terraform_rds_SG"
  }
}

resource "aws_db_subnet_group" "terraform_rds_subnet_group" {
  name        = "terraform_rds_subnet_group"
  description = "this subnet for the terraform rds"
  subnet_ids  = [for subnet in aws_subnet.terraform_private_subnet : subnet.id]
}

resource "aws_db_instance" "terraform_rds" {
  allocated_storage     = var.settings.database.allocated_storage
  engine                = var.settings.database.engine
  engine_version        = var.settings.database.engine_version
  instance_class        = var.settings.database.instance_class
  db_name               = var.settings.database.db_name
  username              = var.db_username
  password              = var.db_password
  db_subnet_group_name  = aws_db_subnet_group.terraform_rds_subnet_group.id
  vpc_security_group_ids = [aws_security_group.terraform_rds_SG.id]
  skip_final_snapshot   = var.settings.database.skip_final_snapshot
}

resource "aws_key_pair" "terraform_kp" {
  key_name   = "terraform_kp"
  public_key = file("terraform_kp.pub")
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

resource "aws_instance" "terraform-web" {
  count                     = var.settings.web_app.count
  ami                       = data.aws_ami.ubuntu.id
  instance_type             = var.settings.web_app.instance_type
  subnet_id                 = aws_subnet.terraform_public_subnet[count.index].id
  key_name                  = aws_key_pair.terraform_kp.key_name
  vpc_security_group_ids    = [aws_security_group.terraform_web_SG.id]

  tags = {
    Name = "terraform-web_${count.index}"
    Date = "14/5/2024"
  }
}

resource "aws_eip" "terraform_web_eip" {
  count     = var.settings.web_app.count
  instance  = aws_instance.terraform-web[count.index].id
  vpc       = true

  tags = {
    Name = "terraform_web_eip_${count.index}"
  }
}

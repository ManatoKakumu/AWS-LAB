terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-northeast-1"
}

resource "aws_vpc" "vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "vpc"
  }
}

resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

variable "db_subnets" {
  type = map(object({
    cidr_block        = string
    availability_zone = string
  }))
  default = {
    az1 = { cidr_block = "10.0.2.0/24", availability_zone = "ap-northeast-1a" }
    az2 = { cidr_block = "10.0.3.0/24", availability_zone = "ap-northeast-1c" }
  }
}

resource "aws_subnet" "db" {
  for_each          = var.db_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = {
    Name = "${each.key}-db-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table" "db" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "db-rt"
  }
}

resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "db" {
  for_each       = var.db_subnets
  subnet_id      = aws_subnet.db[each.key].id
  route_table_id = aws_route_table.db.id
}

resource "aws_security_group" "public" {
  name   = "public-sg"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "public-sg"
  }
}

resource "aws_security_group" "db" {
  name   = "db-sg"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "db-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "ssh-to-ec2" {
  security_group_id = aws_security_group.public.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 22
  to_port     = 22
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "dns-from-ec2" {
  security_group_id = aws_security_group.public.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 53
  to_port     = 53
  ip_protocol = "udp"
}

resource "aws_vpc_security_group_egress_rule" "http-from-ec2" {
  security_group_id = aws_security_group.public.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "https-from-ec2" {
  security_group_id = aws_security_group.public.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "db-from-ec2" {
  security_group_id = aws_security_group.public.id

  referenced_security_group_id = aws_security_group.db.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "db-from-ec2" {
  security_group_id = aws_security_group.db.id

  referenced_security_group_id = aws_security_group.public.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "db-from-db-1" {
  security_group_id = aws_security_group.db.id

  referenced_security_group_id = aws_security_group.db.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "db-from-db-2" {
  security_group_id = aws_security_group.db.id

  referenced_security_group_id = aws_security_group.db.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_network_acl" "public" {
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.public.id]
}

resource "aws_network_acl" "db" {
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [for s in aws_subnet.db : s.id]
}

resource "aws_network_acl_rule" "ssh" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 1
  protocol       = "tcp"
  from_port      = 22
  to_port        = 22
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  egress         = false
}

resource "aws_network_acl_rule" "ephemeral-tcp-in" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 2
  protocol       = "tcp"
  from_port      = 1024
  to_port        = 65535
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  egress         = false
}

resource "aws_network_acl_rule" "ephemeral-udp" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 3
  protocol       = "udp"
  from_port      = 1024
  to_port        = 65535
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  egress         = false
}

resource "aws_network_acl_rule" "ephemeral-tcp-out" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 1
  protocol       = "tcp"
  from_port      = 1024
  to_port        = 65535
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  egress         = true
}

resource "aws_network_acl_rule" "dns" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 2
  protocol       = "udp"
  from_port      = 53
  to_port        = 53
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  egress         = true
}

resource "aws_network_acl_rule" "http" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 3
  protocol       = "tcp"
  from_port      = 80
  to_port        = 80
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  egress         = true
}

resource "aws_network_acl_rule" "https" {
  network_acl_id = aws_network_acl.public.id
  rule_number    = 4
  protocol       = "tcp"
  from_port      = 443
  to_port        = 443
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  egress         = true
}

resource "aws_network_acl_rule" "db-nacl-in" {
  network_acl_id = aws_network_acl.db.id
  rule_number    = 1
  protocol       = "tcp"
  from_port      = 1024
  to_port        = 65535
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  egress         = false
}

resource "aws_network_acl_rule" "db-nacl-out" {
  network_acl_id = aws_network_acl.db.id
  rule_number    = 1
  protocol       = "tcp"
  from_port      = 1024
  to_port        = 65535
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  egress         = true
}

data "aws_ssm_parameter" "al2023" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-6.1-x86_64"
}

resource "aws_instance" "ec2" {
  ami                    = data.aws_ssm_parameter.al2023.value
  instance_type          = "t3.micro"
  subnet_id              = aws_subnet.public.id
  vpc_security_group_ids = [aws_security_group.public.id]

  user_data = <<-EOF
    #!/bin/bash
    dnf install -y mariadb105
    EOF

  tags = {
    Name = "ec2"
  }
}

resource "aws_db_subnet_group" "db" {
  name       = "rds-scaling-subnet-group"
  subnet_ids = [for s in aws_subnet.db : s.id]
}

variable "db_password" {
  type      = string
  sensitive = true
}

resource "aws_db_instance" "primary" {
  identifier              = "rds-scaling-primary"
  engine                  = "mysql"
  instance_class          = "db.t3.micro"
  allocated_storage       = 20
  storage_type            = "gp2"
  db_subnet_group_name    = aws_db_subnet_group.db.name
  vpc_security_group_ids  = [aws_security_group.db.id]
  multi_az                = true
  username                = "admin"
  password                = var.db_password
  skip_final_snapshot     = true
  backup_retention_period = 1
  storage_encrypted       = true
}

resource "aws_db_instance" "replica" {
  identifier             = "rds-scaling-replica"
  instance_class         = "db.t3.micro"
  replicate_source_db    = aws_db_instance.primary.identifier
  vpc_security_group_ids = [aws_security_group.db.id]
  multi_az               = true
  skip_final_snapshot    = true
}

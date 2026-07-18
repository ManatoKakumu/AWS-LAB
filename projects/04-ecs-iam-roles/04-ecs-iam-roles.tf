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

resource "aws_subnet" "ecs-subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-northeast-1d"

  tags = {
    Name = "ecs-subnet"
  }
}

resource "aws_subnet" "nat-subnet" {
  vpc_id                  = aws_vpc.vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-northeast-1d"

  tags = {
    Name = "nat-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_eip" "nat-eip" {
  domain = "vpc"

  tags = {
    Name = "nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat-eip.id
  subnet_id     = aws_subnet.nat-subnet.id
  depends_on    = [aws_internet_gateway.igw]

  tags = {
    Name = "nat"
  }
}

resource "aws_route_table" "ecs-rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "ecs-rtb"
  }
}

resource "aws_route_table" "nat-rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "nat-rtb"
  }
}

resource "aws_route_table_association" "ecs-subnet-rtb" {
  subnet_id      = aws_subnet.ecs-subnet.id
  route_table_id = aws_route_table.ecs-rtb.id
}

resource "aws_route_table_association" "nat-subnet-rtb" {
  subnet_id      = aws_subnet.nat-subnet.id
  route_table_id = aws_route_table.nat-rtb.id
}

resource "aws_security_group" "ecs-sg" {
  name   = "ecs-sg"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "ecs-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.ecs-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "dns" {
  security_group_id = aws_security_group.ecs-sg.id

  cidr_ipv4   = "10.0.0.0/16"
  from_port   = 53
  to_port     = 53
  ip_protocol = "udp"
}

resource "aws_s3_bucket" "upload" {
  bucket = "04-ecs-iam-roles-upload-x8venjb23a"

  tags = {
    Name = "04-ecs-iam-roles-upload"
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/04-ecs-iam-roles"
  retention_in_days = 1

  tags = {
    Name = "04-ecs-iam-roles"
  }
}

resource "aws_ecr_repository" "app" {
  name                 = "04-ecs-iam-roles-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = false
  }

  tags = {
    Name = "04-ecs-iam-roles-app"
  }
}

resource "aws_iam_role" "execution" {
  name = "04-ecs-iam-roles-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "execution" {
  name = "04-ecs-iam-roles-execution-role"
  role = aws_iam_role.execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "ECRAuth"
        Effect   = "Allow"
        Action   = "ecr:GetAuthorizationToken"
        Resource = "*"
      },
      {
        Sid    = "ECRPull"
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = aws_ecr_repository.app.arn
      },
      {
        Sid    = "Logs"
        Effect = "Allow"
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "${aws_cloudwatch_log_group.ecs.arn}:*"
      }
    ]
  })
}

resource "aws_iam_role" "task" {
  name = "04-ecs-iam-roles-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy" "task" {
  name = "04-ecs-iam-roles-task-role"
  role = aws_iam_role.task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "S3Upload"
        Effect   = "Allow"
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.upload.arn}/*"
      }
    ]
  })
}

resource "aws_ecs_cluster" "this" {
  name = "04-ecs-iam-roles-cluster"

  tags = {
    Name = "04-ecs-iam-roles-cluster"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "04-ecs-iam-roles"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name       = "aws-cli"
      image      = "${aws_ecr_repository.app.repository_url}:latest"
      essential  = true
      entryPoint = ["sh", "-c"]
      command = [
        "echo test > /tmp/test.txt && aws s3 cp /tmp/test.txt s3://${aws_s3_bucket.upload.bucket}/test.txt"
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ecs.name
          "awslogs-region"        = "ap-northeast-1"
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}

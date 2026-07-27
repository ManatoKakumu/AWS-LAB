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

locals {
  alb_subnets = {
    az1 = { cidr_block = "10.0.1.0/24", availability_zone = "ap-northeast-1a" }
    az2 = { cidr_block = "10.0.11.0/24", availability_zone = "ap-northeast-1c" }
  }
}

locals {
  ecs_subnets = {
    az1 = { cidr_block = "10.0.3.0/24", availability_zone = "ap-northeast-1a" }
    az2 = { cidr_block = "10.0.13.0/24", availability_zone = "ap-northeast-1c" }
  }
}

resource "aws_subnet" "alb" {
  for_each          = local.alb_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = {
    Name = "${each.key}-alb-subnet"
  }
}

resource "aws_subnet" "nat-subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "nat-subnet"
  }
}

resource "aws_subnet" "ecs" {
  for_each          = local.ecs_subnets
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = each.value.cidr_block
  availability_zone = each.value.availability_zone

  tags = {
    Name = "${each.key}-ecs-subnet"
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

resource "aws_route_table" "alb-rtb" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "alb-rtb"
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

resource "aws_route_table" "ecs-rtb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "ecs-rtb"
  }
}

resource "aws_route_table_association" "alb-subnet-rtb" {
  for_each       = local.alb_subnets
  subnet_id      = aws_subnet.alb[each.key].id
  route_table_id = aws_route_table.alb-rtb.id
}

resource "aws_route_table_association" "nat-subnet-rtb" {
  subnet_id      = aws_subnet.nat-subnet.id
  route_table_id = aws_route_table.nat-rtb.id
}

resource "aws_route_table_association" "ecs-subnet-rtb" {
  for_each       = local.ecs_subnets
  subnet_id      = aws_subnet.ecs[each.key].id
  route_table_id = aws_route_table.ecs-rtb.id
}

resource "aws_security_group" "alb-sg" {
  name   = "alb-sg"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_security_group" "ecs-sg" {
  name   = "ecs-sg"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "ecs-sg"
  }
}

resource "aws_vpc_security_group_egress_rule" "alb-to-ecs" {
  security_group_id = aws_security_group.alb-sg.id

  referenced_security_group_id = aws_security_group.ecs-sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "from-alb" {
  security_group_id = aws_security_group.ecs-sg.id

  referenced_security_group_id = aws_security_group.alb-sg.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "dns" {
  security_group_id = aws_security_group.ecs-sg.id

  cidr_ipv4   = "10.0.0.0/16"
  from_port   = 53
  to_port     = 53
  ip_protocol = "udp"
}

resource "aws_vpc_security_group_egress_rule" "https" {
  security_group_id = aws_security_group.ecs-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_network_acl" "abnormality" {
  vpc_id     = aws_vpc.vpc.id
  subnet_ids = [aws_subnet.ecs["az2"].id]
}

resource "aws_network_acl_rule" "inbound1" {
  network_acl_id = aws_network_acl.abnormality.id
  rule_number    = 1
  protocol       = "tcp"
  rule_action    = "deny"
  cidr_block     = "0.0.0.0/0"
  from_port      = 80
  to_port        = 80
  egress         = false
}

resource "aws_network_acl_rule" "inbound2" {
  network_acl_id = aws_network_acl.abnormality.id
  rule_number    = 2
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  egress         = false
}

resource "aws_network_acl_rule" "outbound" {
  network_acl_id = aws_network_acl.abnormality.id
  rule_number    = 1
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  egress         = true
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/06-multi-az-failure-simulation"
  retention_in_days = 1

  tags = {
    Name = "06-multi-az-failure-simulation"
  }
}

resource "aws_iam_role" "execution" {
  name = "06-multi-az-failure-simulation"

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
  name = "06-multi-az-failure-simulation"
  role = aws_iam_role.execution.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
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

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = true
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
  subnets            = [for s in aws_subnet.alb : s.id]

  tags = {
    Name = "alb"
  }
}

resource "aws_lb_target_group" "ecs-tg" {
  name                 = "ecs-tg"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = aws_vpc.vpc.id
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    path                = "/"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "alb-listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ecs-tg.arn
  }
}

resource "aws_ecs_cluster" "this" {
  name = "06-multi-az-failure-simulation"

  tags = {
    Name = "06-multi-az-failure-simulation"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "06-multi-az-failure-simulation"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.execution.arn

  container_definitions = jsonencode([
    {
      name  = "nginx"
      image = "nginx:latest"

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
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

resource "aws_ecs_service" "nginx" {
  name                   = "nginx"
  cluster                = aws_ecs_cluster.this.id
  task_definition        = aws_ecs_task_definition.app.arn
  desired_count          = 4
  launch_type            = "FARGATE"

  network_configuration {
    subnets          = [for s in aws_subnet.ecs : s.id]
    security_groups  = [aws_security_group.ecs-sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs-tg.arn
    container_name   = "nginx"
    container_port   = 80
  }
}

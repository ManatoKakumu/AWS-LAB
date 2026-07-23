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

resource "aws_subnet" "ecs-subnet" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "ecs-subnet"
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

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

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
  subnet_id      = aws_subnet.ecs-subnet.id
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

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.alb-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
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

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/05-ecs-autoscaling"
  retention_in_days = 1

  tags = {
    Name = "05-ecs-autoscaling"
  }
}

locals {
  ecs_tasks_trust_policy = jsonencode({
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

resource "aws_iam_role" "execution" {
  name               = "05-ecs-autoscaling-execution-role"
  assume_role_policy = local.ecs_tasks_trust_policy
}

resource "aws_iam_role" "task" {
  name               = "05-ecs-autoscaling-task-role"
  assume_role_policy = local.ecs_tasks_trust_policy
}

resource "aws_iam_role_policy" "execution" {
  name = "05-ecs-autoscaling-execution-role"
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

resource "aws_iam_role_policy" "task" {
  name = "05-ecs-autoscaling-task-role"
  role = aws_iam_role.task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ssm"
        Effect = "Allow"
        Action = [
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
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
  name = "05-ecs-autoscaling-cluster"

  tags = {
    Name = "05-ecs-autoscaling-cluster"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "05-ecs-autoscaling"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "1024"
  memory                   = "2048"
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

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
  desired_count          = 1
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = [aws_subnet.ecs-subnet.id]
    security_groups  = [aws_security_group.ecs-sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ecs-tg.arn
    container_name   = "nginx"
    container_port   = 80
  }
}

resource "aws_appautoscaling_target" "scaling-target" {
  max_capacity       = 2
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.this.name}/${aws_ecs_service.nginx.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs-scaling" {
  name               = "ecs-scaling"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.scaling-target.resource_id
  scalable_dimension = aws_appautoscaling_target.scaling-target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.scaling-target.service_namespace

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = 70
  }
}

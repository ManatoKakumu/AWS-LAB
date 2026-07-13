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

resource "aws_subnet" "az1-alb" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "az1-alb-subnet"
  }
}

resource "aws_subnet" "az1-nat" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "az1-nat-subnet"
  }
}

resource "aws_subnet" "az1-web" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "az1-web-subnet"
  }
}

resource "aws_subnet" "az1-ap" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "az1-ap-subnet"
  }
}

resource "aws_subnet" "az1-rds" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.5.0/24"
  availability_zone = "ap-northeast-1a"

  tags = {
    Name = "az1-rds-subnet"
  }
}

resource "aws_subnet" "az2-alb" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "az2-alb-subnet"
  }
}

resource "aws_subnet" "az2-nat" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "az2-nat-subnet"
  }
}

resource "aws_subnet" "az2-web" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.13.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "az2-web-subnet"
  }
}

resource "aws_subnet" "az2-ap" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.14.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "az2-ap-subnet"
  }
}

resource "aws_subnet" "az2-rds" {
  vpc_id            = aws_vpc.vpc.id
  cidr_block        = "10.0.15.0/24"
  availability_zone = "ap-northeast-1c"

  tags = {
    Name = "az2-rds-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "igw"
  }
}

resource "aws_eip" "az1-eip" {
  domain = "vpc"

  tags = {
    Name = "az1-eip"
  }
}

resource "aws_nat_gateway" "az1-nat" {
  allocation_id = aws_eip.az1-eip.id
  subnet_id     = aws_subnet.az1-nat.id

  tags = {
    Name = "az1-nat"
  }
}

resource "aws_eip" "az2-eip" {
  domain = "vpc"

  tags = {
    Name = "az2-eip"
  }
}

resource "aws_nat_gateway" "az2-nat" {
  allocation_id = aws_eip.az2-eip.id
  subnet_id     = aws_subnet.az2-nat.id

  tags = {
    Name = "az2-nat"
  }
}

resource "aws_route_table" "alb" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "alb-rt"
  }
}

resource "aws_route_table_association" "az1-alb" {
  subnet_id      = aws_subnet.az1-alb.id
  route_table_id = aws_route_table.alb.id
}

resource "aws_route_table_association" "az2-alb" {
  subnet_id      = aws_subnet.az2-alb.id
  route_table_id = aws_route_table.alb.id
}

resource "aws_route_table" "nat" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "nat-rt"
  }
}

resource "aws_route_table_association" "az1-nat" {
  subnet_id      = aws_subnet.az1-nat.id
  route_table_id = aws_route_table.nat.id
}

resource "aws_route_table_association" "az2-nat" {
  subnet_id      = aws_subnet.az2-nat.id
  route_table_id = aws_route_table.nat.id
}

resource "aws_route_table" "az1-web" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.az1-nat.id
  }

  tags = {
    Name = "az1-web-rt"
  }
}

resource "aws_route_table_association" "az1-web" {
  subnet_id      = aws_subnet.az1-web.id
  route_table_id = aws_route_table.az1-web.id
}

resource "aws_route_table" "az2-web" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.az2-nat.id
  }

  tags = {
    Name = "az2-web-rt"
  }
}

resource "aws_route_table_association" "az2-web" {
  subnet_id      = aws_subnet.az2-web.id
  route_table_id = aws_route_table.az2-web.id
}

resource "aws_route_table" "az1-ap" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.az1-nat.id
  }

  tags = {
    Name = "az1-ap-rt"
  }
}

resource "aws_route_table_association" "az1-ap" {
  subnet_id      = aws_subnet.az1-ap.id
  route_table_id = aws_route_table.az1-ap.id
}

resource "aws_route_table" "az2-ap" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.az2-nat.id
  }

  tags = {
    Name = "az2-ap-rt"
  }
}

resource "aws_route_table_association" "az2-ap" {
  subnet_id      = aws_subnet.az2-ap.id
  route_table_id = aws_route_table.az2-ap.id
}

resource "aws_route_table" "rds" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "rds-rt"
  }
}

resource "aws_route_table_association" "az1-rds" {
  subnet_id      = aws_subnet.az1-rds.id
  route_table_id = aws_route_table.rds.id
}

resource "aws_route_table_association" "az2-rds" {
  subnet_id      = aws_subnet.az2-rds.id
  route_table_id = aws_route_table.rds.id
}

resource "aws_security_group" "alb" {
  name   = "alb-sg"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "alb-sg"
  }
}

resource "aws_security_group" "web" {
  name   = "web-sg"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "web-sg"
  }
}

resource "aws_security_group" "ap" {
  name   = "ap-sg"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "ap-sg"
  }
}

resource "aws_security_group" "rds" {
  name   = "rds-sg"
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "rds-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.alb.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb-to-web" {
  security_group_id = aws_security_group.alb.id

  referenced_security_group_id = aws_security_group.web.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "alb-to-ap" {
  security_group_id = aws_security_group.alb.id

  referenced_security_group_id = aws_security_group.ap.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "web-from-alb" {
  security_group_id = aws_security_group.web.id

  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "web-to-nat" {
  security_group_id = aws_security_group.web.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "ap-from-alb" {
  security_group_id = aws_security_group.ap.id

  referenced_security_group_id = aws_security_group.alb.id
  from_port                    = 80
  to_port                      = 80
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ap-to-rds" {
  security_group_id = aws_security_group.ap.id

  referenced_security_group_id = aws_security_group.rds.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_vpc_security_group_egress_rule" "ap-to-nat" {
  security_group_id = aws_security_group.ap.id

  cidr_ipv4   = "0.0.0.0/0"
  from_port   = 443
  to_port     = 443
  ip_protocol = "tcp"
}

resource "aws_vpc_security_group_ingress_rule" "rds-from-ap" {
  security_group_id = aws_security_group.rds.id

  referenced_security_group_id = aws_security_group.ap.id
  from_port                    = 3306
  to_port                      = 3306
  ip_protocol                  = "tcp"
}

resource "aws_lb" "alb" {
  name               = "alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = [aws_subnet.az1-alb.id, aws_subnet.az2-alb.id]

  tags = {
    Name = "alb"
  }
}

resource "aws_lb_target_group" "web-target" {
  name        = "web-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"

  health_check {
    path = "/"
  }

  tags = {
    Name = "web-tg"
  }
}

resource "aws_lb_target_group" "ap-target" {
  name        = "ap-tg"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.vpc.id
  target_type = "ip"

  health_check {
    path = "/"
  }

  tags = {
    Name = "ap-tg"
  }
}

resource "aws_lb_listener" "alb" {
  load_balancer_arn = aws_lb.alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web-target.arn
  }
}

resource "aws_lb_listener_rule" "alb" {
  listener_arn = aws_lb_listener.alb.arn
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.ap-target.arn
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }
}

resource "aws_iam_role" "execution" {
  name = "ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "execution" {
  role       = aws_iam_role.execution.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "web" {
  name              = "/ecs/web"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_group" "ap" {
  name              = "/ecs/ap"
  retention_in_days = 30
}

resource "aws_ecs_cluster" "example" {
  name = "example-cluster"
}

resource "aws_iam_role" "task" {
  name = "ecs-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_ecs_task_definition" "web" {
  family                   = "web"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "web"
      image     = "nginx:latest"
      essential = true

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.web.name
          "awslogs-region"        = "ap-northeast-1"
          "awslogs-stream-prefix" = "web"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "web" {
  name            = "web-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.web.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.az1-web.id, aws_subnet.az2-web.id]
    security_groups  = [aws_security_group.web.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.web-target.arn
    container_name   = "web"
    container_port   = 80
  }
}

resource "aws_ecs_task_definition" "ap" {
  family                   = "ap"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.execution.arn
  task_role_arn            = aws_iam_role.task.arn

  container_definitions = jsonencode([
    {
      name      = "ap"
      image     = "nginx:latest"
      essential = true

      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.ap.name
          "awslogs-region"        = "ap-northeast-1"
          "awslogs-stream-prefix" = "ap"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "ap" {
  name            = "ap-service"
  cluster         = aws_ecs_cluster.example.id
  task_definition = aws_ecs_task_definition.ap.arn
  desired_count   = 2
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [aws_subnet.az1-ap.id, aws_subnet.az2-ap.id]
    security_groups  = [aws_security_group.ap.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.ap-target.arn
    container_name   = "ap"
    container_port   = 80
  }
}

variable "db_password" {
  type      = string
  sensitive = true
}

resource "aws_db_subnet_group" "rds" {
  name       = "rdb-subnet-group"
  subnet_ids = [aws_subnet.az1-rds.id, aws_subnet.az2-rds.id]
}

resource "aws_db_instance" "rdb" {
  identifier             = "rdb"
  engine                 = "mysql"
  instance_class         = "db.t3.micro"
  allocated_storage      = 20
  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  multi_az               = true
  username                = "admin"
  password                = var.db_password
  skip_final_snapshot     = true
  storage_encrypted       = true
}

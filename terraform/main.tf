# Configure the AWS provider
provider "aws" {
  region = var.aws_region
}

# 1. A Security Group to allow HTTP traffic to our container
resource "aws_security_group" "ecs_sg" {
  name        = "ecs-flask-app-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] // Allow traffic from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ecs-flask-app-sg"
  }
}

# 2. The ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "flask-cluster"
}

# 3. The ECS Task Definition (blueprint for the app)
resource "aws_ecs_task_definition" "app" {
  family                   = "flask-app-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"  # 0.25 vCPU
  memory                   = "512"  # 0.5 GB
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name      = "flask-app-container"
      image     = var.app_image
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])
}

# 4. The ECS Service to run and maintain our task
resource "aws_ecs_service" "main" {
  name            = "flask-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets         = [var.subnet_id]
    security_groups = [aws_security_group.ecs_sg.id]
    assign_public_ip = true # Give our task a public IP to access it
  }

  # Wait for the service to be stable before considering the apply complete
  depends_on = [aws_iam_role_policy_attachment.ecs_task_execution_role_policy]
}


# 5. An IAM Role that allows ECS to pull images from ECR
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs_task_execution_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Action = "sts:AssumeRole",
      Effect = "Allow",
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}
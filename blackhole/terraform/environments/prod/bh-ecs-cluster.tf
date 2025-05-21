resource "aws_ecs_cluster" "bh_ecs_cluster" {
  name = "bh-ecs-cluster"
}

resource "aws_lb" "bh_ecs_alb" {
  name               = "bh-ecs-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.bh_ecs_alb_sg.id]
  subnets            = ["${var.public_subnet_ids}"] # TODO: Set your public subnet IDs
}

resource "aws_security_group" "bh_ecs_alb_sg" {
  name        = "bh-ecs-alb-sg"
  description = "Allow HTTP and HTTPS traffic to ALB"
  vpc_id      = var.vpc_id # TODO: Set your VPC ID

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "bh_ecs_tg" {
  name     = "bh-ecs-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id # TODO: Set your VPC ID
  target_type = "ip"
  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200-399"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "bh_ecs_listener" {
  load_balancer_arn = aws_lb.bh_ecs_alb.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.bh_ecs_tg.arn
  }
}

resource "aws_ecs_task_definition" "bh_ecs_task" {
  family                   = "bh-ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  container_definitions    = <<DEFINITION
[
  {
    "name": "bh-ecs-container",
    "image": "<ECR_IMAGE_URI>", // TODO: Set to your ECR image URI (same as staging)
    "portMappings": [
      {
        "containerPort": 80,
        "hostPort": 80
      }
    ],
    "environment": [
      // TODO: Add environment variables if needed
    ]
  }
]
DEFINITION
}

resource "aws_ecs_service" "bh_ecs_service" {
  name            = "bh-ecs-service"
  cluster         = aws_ecs_cluster.bh_ecs_cluster.id
  task_definition = aws_ecs_task_definition.bh_ecs_task.arn
  desired_count   = 2
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = ["${var.private_subnet_ids}"] # TODO: Set your private subnet IDs
    security_groups  = [aws_security_group.bh_ecs_service_sg.id]
    assign_public_ip = false
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.bh_ecs_tg.arn
    container_name   = "bh-ecs-container"
    container_port   = 80
  }
  depends_on = [aws_lb_listener.bh_ecs_listener]
}

resource "aws_security_group" "bh_ecs_service_sg" {
  name        = "bh-ecs-service-sg"
  description = "Allow traffic from ALB to ECS"
  vpc_id      = var.vpc_id # TODO: Set your VPC ID

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.bh_ecs_alb_sg.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecsTaskExecutionRole"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role_policy.json
}

data "aws_iam_policy_document" "ecs_task_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

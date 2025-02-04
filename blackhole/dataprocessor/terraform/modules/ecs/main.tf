resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
  
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_task_definition" "app" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  # Add volume definitions for Datadog
  volume {
    name = "pointdir"
  }

  volume {
    name = "containers_root"
  }

  container_definitions = jsonencode([
    {
      name      = "app"
      image     = "${var.ecr_repo_url}:latest"
      essential = true
      cpu       = floor(var.fargate_cpu * 0.5)
      memory    = floor(var.fargate_memory * 0.5)
      command   = ["poetry", "run", "daphne", "-b", "0.0.0.0", "-p", "8000", "comet.asgi:application"]
      portMappings = [{
        containerPort = var.app_port
        hostPort      = var.app_port
        protocol      = "tcp"
      }]
      environment = [
        {
          name  = "PORT"
          value = tostring(var.app_port)
        }
      ]
      secrets = [
        for key, arn in var.ssm_parameter_arns : {
          name      = upper(key)
          valueFrom = arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs-web"
        }
      }
    },
    {
      name      = "celery-worker"
      image     = "${var.ecr_repo_url}:latest"
      essential = true
      cpu       = floor(var.fargate_cpu * 0.25)
      memory    = floor(var.fargate_memory * 0.33)
      command   = ["poetry", "run", "celery", "-A", "comet", "worker", "--loglevel=info"]
      environment = []
      secrets = [
        for key, arn in var.ssm_parameter_arns : {
          name      = upper(key)
          valueFrom = arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs-worker"
        }
      }
    },
    {
      name      = "datadog-agent"
      image     = "public.ecr.aws/datadog/agent:latest"
      cpu       = floor(var.fargate_cpu * 0.06)
      memory    = floor(var.fargate_memory * 0.08)
      essential = true
      mountPoints = [
        {
          sourceVolume  = "pointdir"
          containerPath = "/opt/datadog-agent/run"
          readOnly      = false
        },
        {
          sourceVolume  = "containers_root"
          containerPath = "/var/lib/docker/containers"
          readOnly      = true
        }
      ]
      environment = [
        {
          name  = "DD_SITE"
          value = "datadoghq.com"
        },
        {
          name  = "DD_LOGS_ENABLED"
          value = "true"
        },
        {
          name  = "DD_LOGS_CONFIG_CONTAINER_COLLECT_ALL"
          value = "true"
        },
        {
          name  = "DD_CONTAINER_EXCLUDE"
          value = "name:datadog-agent"
        },
        {
          name  = "DD_APM_ENABLED"
          value = "true"
        },
        {
          name  = "ECS_FARGATE"
          value = "true"
        }
      ]
      secrets = [
        {
          name      = "DD_API_KEY"
          valueFrom = var.datadog_api_key_ssm_parameter_arn
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "celery_beat" {
  family                   = "${var.project_name}-celery-beat"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }

  container_definitions = jsonencode([
    {
      name      = "celery-beat"
      image     = "${var.ecr_repo_url}:latest"
      essential = true
      command   = ["poetry", "run", "celery", "-A", "comet", "beat", "--loglevel=info"]
      environment = []
      secrets = [
        for key, arn in var.ssm_parameter_arns : {
          name      = upper(key)
          valueFrom = arn
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_logs.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "ecs-beat"
        }
      }
    }
  ])
}

resource "aws_ecs_service" "main" {
  name                               = "${var.project_name}-service"
  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = aws_ecs_task_definition.app.arn
  desired_count                     = var.app_count
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0"
  propagate_tags                    = "SERVICE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets         = var.private_subnets
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = "app"
    container_port   = var.app_port
  }

  deployment_maximum_percent         = 200
  deployment_minimum_healthy_percent = 100
  health_check_grace_period_seconds = 60

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  enable_execute_command = true
  
  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [var.alb_listener_http, var.alb_listener_https]
}

resource "aws_ecs_service" "celery_beat" {
  name                               = "${var.project_name}-celery-beat"
  cluster                           = aws_ecs_cluster.main.id
  task_definition                   = aws_ecs_task_definition.celery_beat.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0"
  propagate_tags                    = "SERVICE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets         = var.private_subnets
    assign_public_ip = false
  }

  deployment_maximum_percent         = 100
  deployment_minimum_healthy_percent = 0
  enable_execute_command            = true

  lifecycle {
    ignore_changes = [desired_count]
  }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-ecs-tasks-sg-1"
  description = "Security group for ECS tasks"
  vpc_id      = var.vpc_id

  ingress {
    protocol        = "tcp"
    from_port       = var.app_port
    to_port         = var.app_port
    security_groups = [var.alb_security_group_id]
    description     = "Allow inbound traffic from ALB"
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "${var.project_name}-ecs-tasks-sg-1"
  }
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 30
  
  tags = {
    Name = "${var.project_name}-ecs-logs"
  }
}

resource "aws_iam_role" "ecs_execution_role" {
  name = "${var.project_name}-ecs-execution-role"

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

  tags = {
    Name = "${var.project_name}-ecs-execution-role"
  }
}

resource "aws_iam_role" "ecs_task_role" {
  name = "${var.project_name}-ecs-task-role"

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

  tags = {
    Name = "${var.project_name}-ecs-task-role"
  }
}

resource "aws_iam_policy" "ssm_access_policy" {
  name        = "${var.project_name}-ssm-access-policy"
  description = "Allow access to SSM parameters"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Action = [
        "ssm:GetParameters",
        "ssm:GetParameter",
        "ssm:GetParametersByPath"
      ]
      Resource = concat(
        values(var.ssm_parameter_arns),
        [var.datadog_api_key_ssm_parameter_arn]
      )
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_ssm_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = aws_iam_policy.ssm_access_policy.arn
}

resource "aws_iam_role_policy_attachment" "ecs_task_role_ssm_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ssm_access_policy.arn
}

resource "aws_iam_policy" "ecs_exec_policy" {
  name        = "${var.project_name}-ecs-exec-policy"
  description = "Allow ECS Exec"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
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

resource "aws_iam_role_policy_attachment" "ecs_task_role_exec_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = aws_iam_policy.ecs_exec_policy.arn
}
resource "aws_ecs_cluster" "aws-ecs-cluster" {
  name = "${var.env}-${var.project_name}-${var.service_name}"
  configuration {
    execute_command_configuration {
      logging = "OVERRIDE"

      log_configuration {
        cloud_watch_log_group_name = aws_cloudwatch_log_group.log-group.name
      }
    }
  }
  tags = {
    Name        = "${var.env}-${var.project_name}-${var.service_name}"
    Environment = "${var.env}"
    Management  = "terraform"
  }
}

resource "aws_cloudwatch_log_group" "log-group" {
  name              = "${var.env}-${var.project_name}-${var.service_name}-fargate"
  retention_in_days = var.retention_in_days
  tags = {
    Name        = "${var.env}-${var.project_name}-${var.service_name}-fargate"
    Environment = "${var.env}"
    Management  = "terraform"
  }
}

data "template_file" "task_definition_parameter" {
  template = <<CONTAINER_DEFINITION
[
      {
          "name": "${var.project_name}-container",
          "image": "nginx",
          "essential": true,
          "portMappings": [
                  {
                    "containerPort": ${var.container_port}, 
                    "hostPort": ${var.container_port}
            }
          ],
          "memory": ${var.ecs_task_mem},
          "secrets": [
            {
              "valueFrom": "${var.parameter_path}",
              "name": "env_file"
            }
          ],
          "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
              "awslogs-group": "${aws_cloudwatch_log_group.log-group.name}",
              "awslogs-region": "${var.region}",
              "awslogs-stream-prefix": "ecs"
            }
          }
      }
  ]
CONTAINER_DEFINITION
}

data "template_file" "task_definition" {
  template = <<CONTAINER_DEFINITION
[
      {
          "name": "${var.project_name}-container",
          "image": "nginx",
          "essential": true,
          "portMappings": [
                  {
                    "containerPort": ${var.container_port}, 
                    "hostPort": ${var.container_port}
            }
          ],
          "memory": ${var.ecs_task_mem},
          "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
              "awslogs-group": "${aws_cloudwatch_log_group.log-group.name}",
              "awslogs-region": "${var.region}",
              "awslogs-stream-prefix": "ecs"
            }
          }
      }
  ]
CONTAINER_DEFINITION
}


resource "aws_ecs_task_definition" "aws-ecs-task" {
  family                   = "${var.env}-${var.project_name}-${var.service_name}"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = var.ecs_task_cpu
  memory                   = var.ecs_task_mem
  execution_role_arn       = aws_iam_role.ecsTaskExecutionRole.arn
  task_role_arn            = aws_iam_role.ecsTaskExecutionRole.arn
  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "X86_64"
  }
  container_definitions = var.parameter ? data.template_file.task_definition_parameter.rendered : data.template_file.task_definition.rendered
}


resource "aws_ecs_service" "aws-ecs-service" {
  name                   = "${var.env}-${var.project_name}-${var.service_name}"
  cluster                = aws_ecs_cluster.aws-ecs-cluster.id
  task_definition        = aws_ecs_task_definition.aws-ecs-task.id
  launch_type            = "FARGATE"
  scheduling_strategy    = "REPLICA"
  desired_count          = var.ecs_task_count
  enable_execute_command = true
  force_new_deployment   = true

  network_configuration {
    subnets          = var.subnet_ids
    assign_public_ip = var.assign_public_ip
    security_groups  = aws_security_group.sg-fargate[*].id
  }

  load_balancer {
    target_group_arn = var.target_group_arn[0]
    container_name   = "${var.project_name}-container"
    container_port   = var.container_port
  }
}

#--- Fargate SG  ---
resource "aws_security_group" "sg-fargate" {
  name        = "${var.env}-${var.project_name}-${var.service_name}-fargate-sg"
  description = "Allow ALB to access ECS tasks"
  vpc_id      = var.vpc_id

  ingress = [
    {
      description      = "Allow from ALB"
      from_port        = 0
      to_port          = 0
      protocol         = -1
      cidr_blocks      = var.cidr_ingress
      ipv6_cidr_blocks = null
      prefix_list_ids  = null
      security_groups  = var.sg_ingress
      self             = null
    }
  ]

  egress = [
    {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
      ipv6_cidr_blocks = ["::/0"]
      description      = null
      prefix_list_ids  = null
      security_groups  = null
      self             = null

    }
  ]

  tags = {
    Name        = "${var.env}-${var.project_name}-${var.service_name}-fargate-sg"
    Environment = "${var.env}"
    Management  = "terraform"
  }
}

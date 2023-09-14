# define Cluster
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.name_prefix}-cluster"
}

resource "random_password" "admin_password" {
  length  = 16
  special = false
}

resource "aws_ecs_task_definition" "ecs_task" {
  family                   = "${var.name_prefix}-task"
  task_role_arn            = aws_iam_role.task_exec_role.arn
  execution_role_arn       = aws_iam_role.task_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = var.fargate_cpu
  memory                   = var.fargate_memory
  container_definitions    = templatefile("container-definitions.json.tpl", {
    app_image           = var.app_image
    aws_region          = var.aws_region
    app_port            = var.container_port
    domain              = var.domain
    log_group           = aws_cloudwatch_log_group.log_group.name
    admin_password_hash = sha256(random_password.admin_password.result)
    datastore_endpoint  = "postgres://devpod:${random_password.password.result}@${aws_db_instance.datastore.endpoint}/devpod"
  })

  volume {
    name = "efs-loft"
    efs_volume_configuration {
      file_system_id = aws_efs_file_system.efs_file_system.id
      root_directory = "/"
    }
  }
}

# define Service
resource "aws_ecs_service" "ecs_service" {
  name                   = "${var.name_prefix}-service"
  cluster                = aws_ecs_cluster.ecs_cluster.id
  task_definition        = aws_ecs_task_definition.ecs_task.arn
  desired_count          = var.desired_count
  launch_type            = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks_sg.id]
    subnets          = aws_subnet.public_subnet.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_alb_target_group.alb_target_group.id
    container_name   = var.balanced_container_name
    container_port   = var.container_port
  }

  depends_on = [aws_efs_mount_target.mount, aws_alb_listener.load_balancer_listener]
}
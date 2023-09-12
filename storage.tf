resource "aws_efs_file_system" "efs_file_system" {
  performance_mode = "maxIO"

  tags = {
    Name = "${var.name_prefix}-ecs-efs-fs"
  }
}

resource "aws_efs_mount_target" "mount" {
  count = var.az_count

  file_system_id  = aws_efs_file_system.efs_file_system.id
  subnet_id       = element(aws_subnet.public_subnet.*.id, count.index)
  security_groups = [aws_security_group.ecs_tasks_sg.id]
}
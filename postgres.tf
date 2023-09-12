resource "aws_db_subnet_group" "datastore-sbg" {
  name       = "${var.name_prefix}-datastore-sbg"
  subnet_ids = aws_subnet.private_subnet.*.id

  tags = {
    Name = "${var.name_prefix}-datastore-sbg"
  }
}

resource "random_password" "password" {
  length  = 16
  special = false
}

resource "aws_db_instance" "datastore" {
  identifier             = "${var.name_prefix}-postgres-sg"
  instance_class         = "db.t3.medium"
  allocated_storage      = 5
  engine                 = "postgres"
  skip_final_snapshot    = true
  db_name                = "devpod"
  db_subnet_group_name   = aws_db_subnet_group.datastore-sbg.name
  vpc_security_group_ids = [aws_security_group.postgres_sg.id]
  username               = "devpod"
  password               = random_password.password.result
}



resource "aws_db_instance" "database" {
  identifier          = var.identifier
  engine              = var.engine
  engine_version      = var.engine_version
  instance_class      = var.instance_class
  allocated_storage   = var.allocated_storage
  multi_az            = var.multi_az
  db_name             = var.db_name
  username            = var.username
  password            = var.password
  skip_final_snapshot = true
  deletion_protection = false
  publicly_accessible = false
}

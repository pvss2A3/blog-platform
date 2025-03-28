resource "aws_db_subnet_group" "main" {
  name       = "blog-db-subnet-group"
  subnet_ids = var.private_subnet_ids
  tags = { Name = "BlogDBSubnetGroup" }
}

resource "aws_db_instance" "blog_db" {
  identifier           = "blogdb"
  engine               = "postgres"
  engine_version       = "15.7"
  instance_class       = "db.t3.micro"
  allocated_storage    = 20
  username             = var.db_username
  password             = var.db_password
  db_subnet_group_name = aws_db_subnet_group.main.name
  vpc_security_group_ids = [var.db_sg_id]
  skip_final_snapshot  = true
  tags = { Name = "BlogDB" }
}

output "db_endpoint" {
  value = aws_db_instance.blog_db.endpoint
}
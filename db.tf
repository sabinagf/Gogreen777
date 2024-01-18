resource "aws_db_subnet_group" "database_subnet_group" {
  subnet_ids = [aws_subnet.private_subnets["Private_Sub_DB_1A"].id, aws_subnet.private_subnets["Private_Sub_DB_1B"].id]
}

resource "aws_db_instance" "database_instance" {
  identifier              = "database"
  db_name                 = "gogreen"
  engine                  = "mysql"
  instance_class          = "db.t2.micro"
  username                = "gogreen"
  password                = random_password.database_password.result
  db_subnet_group_name    = aws_db_subnet_group.database_subnet_group.id
  vpc_security_group_ids  = [module.database_security_group.security_group_id["db_sg"]]
  allocated_storage       = 20
  skip_final_snapshot     = true
  backup_retention_period = 0
}



resource "random_password" "database_password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
resource "aws_secretsmanager_secret" "gogreen_mysql_db" {
  name                    = "new_gogreen_database_instance"
  recovery_window_in_days = 0
}
resource "aws_secretsmanager_secret_version" "gogreen_mysql_db" {
  secret_id = aws_secretsmanager_secret.gogreen_mysql_db.id
  secret_string = jsonencode({
    username = "dbadmin"
    password = random_password.database_password.result
    host     = aws_db_instance.database_instance.endpoint
  })
}

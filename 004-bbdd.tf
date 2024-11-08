#en este modulo crearemos todos nuestros recursos relacionados con la BBDD (postgre) que necesitara nuestro CRM
# la contraseña sera administrada por KMS, se generara de forma aleatoria y se introducira en cada instancia
#modificando el archivo wp-config.php
#comente el atributo multi_az ya que eleva los tiempos de carga en su deployment, pero funciona perfectamente


resource "aws_db_subnet_group" "subredparabbdd" {
  name       = "main"
  subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
}

resource "aws_db_instance" "primaria" {
  identifier = "postgresql"
  engine     = "postgres"
  instance_class                  = "db.t3.micro"
  db_subnet_group_name            = aws_db_subnet_group.subredparabbdd.name
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  db_name = "wordpress"
  username = "administrador"
  password                        = jsondecode(data.aws_secretsmanager_secret_version.rds_password_secret_version0.secret_string)["password"]
  #multi_az = true
  allocated_storage               = 20
  max_allocated_storage           = 0
  backup_retention_period         = 15
  delete_automated_backups = true
  backup_window                   = "00:00-00:30"
  maintenance_window              = "Sun:21:00-Sun:21:30"
  storage_type                    = "gp2"
  vpc_security_group_ids          = [aws_security_group.SG_rds.id]
  skip_final_snapshot             = true
  depends_on                      = [aws_security_group.SG_rds, aws_db_subnet_group.subredparabbdd]

  tags = {
        "Name" = "${var.proyecto}-BBDD"
        "Environment" = var.env
        "Owner" = var.tagowner
  }
}


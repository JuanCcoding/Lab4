#este modulo fue super importante, luego de probar cientos de formas de coger la información y meterla en el script.sh
#se me ocurrio la idea de definir un data de tipo template_file, que me permite definir variables dentro y
#referenciarle valores
# de esta forma le "pasamos" los datos a nuestro script, que luego los invocara llamando al nombre de la vars
#tambien aqui creamos el secreto (contraseña) de forma aleatoria que sera asignado como pass de nuestra DDBB

data "template_file" "user_data" {
  template = file("${path.module}/userdata.sh")
   vars = {
    EFS_ID       = aws_efs_file_system.miefs.id
    EFS_DNS = aws_efs_file_system.miefs.dns_name
    DB_NAME      = "wordpress"
    DB_HOSTNAME  = aws_route53_record.bbdd.name
    DB_USERNAME  = "admin123"
    DB_PASSWORD = jsondecode(data.aws_secretsmanager_secret_version.rds_password_secret_version0.secret_string)["password"]
  }
  depends_on = [ aws_db_instance.primaria]
}


# Generar una contraseña aleatoria
resource "random_password" "rds_password" {
  length           = 16
  special          = true      # Incluye caracteres especiales para mayor seguridad
  override_special = "!@#%^&*()-_=+[]{}" # Especifica caracteres especiales permitidos por RDS
}

# Crear el secreto en Secrets Manager para almacenar la contraseña generada
resource "aws_secretsmanager_secret" "rds_password_secret0" {
  name        = "rds-db-password0"
  description = "contraseña autogenerada para la bbdd"
  recovery_window_in_days = 0
}

# Guardar la contraseña aleatoria en Secrets Manager
resource "aws_secretsmanager_secret_version" "rds_password_secret_version0" {
  secret_id     = aws_secretsmanager_secret.rds_password_secret0.id
  secret_string = jsonencode({ password = random_password.rds_password.result })
}

# Obtener el secreto de Secrets Manager
data "aws_secretsmanager_secret" "rds_password_secret0" {
  name = aws_secretsmanager_secret.rds_password_secret0.name
}

data "aws_secretsmanager_secret_version" "rds_password_secret_version0" {
  secret_id = data.aws_secretsmanager_secret.rds_password_secret0.id

}
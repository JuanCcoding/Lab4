#En este modulo creamos un certificado autofirmado para que nuestra web pueda exitosamente salir desde https

# Leer el contenido de los archivos .crt y .key
data "local_file" "certificate" {
  filename = "${path.module}/certificate.crt"
}

data "local_file" "private_key" {
  filename = "${path.module}/private.key"
}


# Importar el certificado en AWS IAM
resource "aws_iam_server_certificate" "autofirmado_cert" {
  name             = "my-autosigned-cert"
  certificate_body = data.local_file.certificate.content
  private_key      = data.local_file.private_key.content


  tags = {
    Name = "AutofirmadoCert"
  }
}

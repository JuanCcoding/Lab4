#En este modulo crearemos todos los recursos necesarios vinculados con el almacenamiento (bucket de S3 y EFS)
#la creacion del efs y su montaje esta apuntando a una carpeta dentro html/efs, en principio alli no hay datos
#puede que no haya consistencia entre los recursos dependiendo de que instancia se conecte
#en un entorno real, evidentemente se hubiese puesto el wordpress-core dentro de /html/efs
#el bucket s3 servira para almacenar las imagenes del sitio, sera cacheado por cloudfront

#creacion del EFS

resource "aws_efs_file_system" "miefs" {
  encrypted      = true
  depends_on     = [aws_security_group.SG_EFS]
  creation_token = "efs"
  throughput_mode = "elastic"
  performance_mode = "generalPurpose"
  
  tags = {
        "Name" = "${var.proyecto}-EFS"
        "Environment" = var.env
        "Owner" = var.tagowner
  }
}

resource "aws_efs_mount_target" "destinoEFS1" {
  file_system_id  = aws_efs_file_system.miefs.id
  subnet_id       = aws_subnet.private1.id
  security_groups = ["${aws_security_group.SG_EFS.id}"]
  

  depends_on = [aws_efs_file_system.miefs, aws_security_group.SG_EFS]
}

resource "aws_efs_mount_target" "destinoEFS2" {
  file_system_id  = aws_efs_file_system.miefs.id
  subnet_id       = aws_subnet.private2.id
  security_groups = ["${aws_security_group.SG_EFS.id}"]

  depends_on = [aws_efs_file_system.miefs, aws_security_group.SG_EFS]
}


resource "aws_efs_access_point" "puntoDeAcesso" {
  depends_on     = [aws_efs_file_system.miefs]
  file_system_id = aws_efs_file_system.miefs.id

}



##### Creating an S3 Bucket #####
resource "aws_s3_bucket" "micubo" {
  bucket        = "cubodejuanlab4"
  force_destroy = true
  

  tags = {
        "Name" = "${var.proyecto}-Bucket"
        "Environment" = var.env
        "Owner" = var.tagowner
  }
}

resource "aws_s3_object" "imagenes" {
  bucket = "cubodejuanlab4"
  key = "imagenes/imagen.png"
  source = "lab4.png"
  cache_control = "max-age=3600" 
  depends_on = [ aws_s3_bucket.micubo ]
}

#configuramos el public acces#
resource "aws_s3_bucket_public_access_block" "public_access_block" {
  bucket                  = aws_s3_bucket.micubo.bucket
  block_public_acls       = true
  block_public_policy     = false
  ignore_public_acls      = true
  restrict_public_buckets = false

}

##### Crear una política de acceso usando el ARN guardado en la variable local #####
resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = aws_s3_bucket.micubo.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect    = "Allow"
        Principal = "*"
        Action    = ["s3:GetObject"]
        Resource = ["${local.s3_bucket_arn}/*"]
      }
    ]
    
  })
  
  
} 


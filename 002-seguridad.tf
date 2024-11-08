#En este modulo crearemos todos los grupos de seguridad necesarios, anianandolos entre ellos 


#SG de las instancias
resource "aws_security_group" "SG_ec2" {
  name        = "SG_para_EC2"
  description = "permite el acceso a mis instancias solo desde el ALB por htpp(80) y https(443) "
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    description     = "http"
    security_groups = [aws_security_group.SG_alb.id]
  }

  ingress {
    description     = "https"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.SG_alb.id]
  }

  egress {
    description = "sale todo"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]

  }

  vpc_id = aws_vpc.mi_VPC.id


  tags = {
    Name = "MisEc2Aisladas"
  }


}

#Grupo de seguridad del ALB

resource "aws_security_group" "SG_alb" {
  name = "miAlb"
  description = "P"
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
     
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  vpc_id = aws_vpc.mi_VPC.id
}

#grupo de seguridad del Elastic File System

resource "aws_security_group" "SG_EFS" {
  depends_on = [
    aws_security_group.SG_ec2,
  ]
  name        = "EFS_EC2"
  description = "PermiteComunicarSoloLasEc2conelEFS "
  vpc_id      = aws_vpc.mi_VPC.id

  ingress {
    from_port       = 2049
    to_port         = 2049
    protocol        = "tcp"                          #-1
    security_groups = [aws_security_group.SG_ec2.id] #de mis instancias
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "tcp" #-1
    cidr_blocks = ["0.0.0.0/0"]
  }


}

#Grupo de seguridad de mi RDS

resource "aws_security_group" "SG_rds" {
  name        = "SG_para_RDS"
  description = "Permite_solo_la_comunicacion_entre_las_ec2_y_la_bbdd"
  vpc_id      = aws_vpc.mi_VPC.id

  ingress {
    description     = "Desde Ec2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.SG_ec2.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  depends_on = [aws_security_group.SG_ec2]
}

#Grupo de seguridad para el cache

resource "aws_security_group" "SG_memcached" {
  name_prefix = "memcached_sg"
  description = "Security group for Memcached cluster"
  vpc_id      = aws_vpc.mi_VPC.id

  ingress {
    from_port   = 11211
    to_port     = 11211
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

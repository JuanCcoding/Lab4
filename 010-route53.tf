#En este modulo crearemos los dominios internos que enmascararan  nuestros dns
#hemos creado un registro para nuestra bdd
#tambien otro para el alb

resource "aws_route53_zone" "mizonaprivada" {
  name = "lab4.com"

  vpc {
    vpc_id = aws_vpc.mi_VPC.id
  }
   tags = {
        "Name" = "${var.proyecto}-Mi zona de Hosting Privado"
        "Environment" = var.env
        "Owner" = var.tagowner
  }

}


resource "aws_route53_record" "bbdd" {
  zone_id    = aws_route53_zone.mizonaprivada.id
  name       = "bbdd.lab4.com"
  type       = "CNAME"
  records    = [aws_db_instance.primaria.address]
  ttl        = 60
  depends_on = [aws_db_instance.primaria]
  
}


resource "aws_route53_record" "alb" {
  zone_id    = aws_route53_zone.mizonaprivada.id
  name       = "alb.lab4.com"
  type       = "CNAME"
  records    = [aws_lb.mialb.dns_name]
  ttl        = 60
  depends_on = [aws_lb.mialb]
}


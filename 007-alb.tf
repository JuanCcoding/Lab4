#en este modulo creamos el recurso de ALB y sus dependencias (target group, listener)
#como ya poseemos un certificado, permitiremos escuchas desde el puerto hhtps
#configuraremos ambos listener y uno de ellos (80) redirigira todo al otro (443)

resource "aws_lb" "mialb" {
  name               = "mialb"
  internal           = false
  load_balancer_type = "application"
  ip_address_type    = "ipv4"
  security_groups    = [aws_security_group.SG_alb.id]
  subnets            = [aws_subnet.public1.id, aws_subnet.public2.id]


  lifecycle {
    create_before_destroy = true
  }
}


resource "aws_lb_listener" "listener_https" {
    load_balancer_arn = aws_lb.mialb.arn
    port = 443
    protocol = "HTTPS"
    ssl_policy = "ELBSecurityPolicy-2016-08"
    certificate_arn = aws_iam_server_certificate.autofirmado_cert.arn


    default_action {
      type = "forward"
      target_group_arn = aws_lb_target_group.mitargetgroup.arn
    } 
     tags = {
        "Name" = "${var.proyecto}-ALB"
        "Environment" = var.env
        "Owner" = var.tagowner
  }
}



# Listener en puerto 80 para redireccionar a HTTPS (443)
resource "aws_lb_listener" "listener_http" {
  load_balancer_arn = aws_lb.mialb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"
    redirect {
      protocol = "HTTPS"
      port     = "443"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_target_group" "mitargetgroup" {
  name        = "miGrupodeDestino"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = aws_vpc.mi_VPC.id
  target_type = "instance"

  lifecycle {
    create_before_destroy = true
  }
  health_check {
    path                = "/salud.html"
    port                = "traffic-port"
    healthy_threshold   = 5
    unhealthy_threshold = 2
    timeout             = 3
    interval            = 10
    matcher             = "200" #200 significa éxito 
  }
   tags = {
        "Name" = "${var.proyecto}-targetG"
        "Environment" = var.env
        "Owner" = var.tagowner
  }
}


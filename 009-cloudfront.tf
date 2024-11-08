
#aqui crearemos nuestra distribución de contenido, tendremos 2 origenes
#1. apuntara todo las peticiones a nuestro alb
#2. apuntara todas las peticiones de recursos con dirección micubo/imagenes

resource "aws_cloudfront_distribution" "distri_cf" {
  origin {
    domain_name = aws_lb.mialb.dns_name  # Dominio del ALB
    origin_id   = "alb"

    custom_origin_config {
      http_port              = 80
      https_port             = 443
      origin_protocol_policy = "http-only"  
      origin_ssl_protocols   = ["TLSv1.2"]

    }
  }

  origin {
  
    domain_name = aws_s3_bucket.micubo.bucket_domain_name  # Dominio del bucket S3
    origin_id   = "S3Origin"

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.s3_identity.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "CloudFront distribution with ALB and S3 bucket origins"
  #default_root_object = "index.php"

  # Comportamiento predeterminado: apunta al ALB
  default_cache_behavior {
    target_origin_id       = "alb"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
  
 

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  # Comportamiento adicional: apunta al bucket de S3
  ordered_cache_behavior {
    path_pattern           = "https://cubodejuanlab4.s3.us-east-1.amazonaws.com/imagenes/"  # Patrón de ruta para el bucket S3
    target_origin_id       = "S3Origin"
    viewer_protocol_policy = "redirect-to-https"
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]

    forwarded_values {
      query_string = false
      cookies {
        forward = "none"
      }
    }

    min_ttl    = 0
    default_ttl = 3600
    max_ttl    = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
   tags = {
        "Name" = "${var.proyecto}-CDN"
        "Environment" = var.env
        "Owner" = var.tagowner
  }
  depends_on = [ aws_lb.mialb, aws_s3_bucket.micubo, aws_elasticache_cluster.memcached_cluster]

}

# Definir el origen de acceso a identidad de CloudFront para S3
resource "aws_cloudfront_origin_access_identity" "s3_identity" {
  comment = "Access Identity for S3 origin in CloudFront"
}

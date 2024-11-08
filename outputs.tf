#aqui pondremos todos los outputs (salida en pantalla de datos) de nuestros recursos mas importantes
# Launch Template Outputs

output "vpc_id" {
value = aws_vpc.mi_VPC.id
}
output "launch_template_id" {
  description = "Launch Template ID"
  value       = aws_launch_template.mi_plantilla.id
}

output "launch_template_latest_version" {
  description = "Launch Template Latest Version"
  value       = aws_launch_template.mi_plantilla.latest_version
}


output "autoscaling_group_id" {
  description = "Autoscaling Group ID"
  value       = aws_autoscaling_group.miASG.id
}

output "autoscaling_group_arn" {
  description = "Autoscaling Group ARN"
  value       = aws_autoscaling_group.miASG.arn
}

output "load_balancer_DNS" {
  value = aws_lb.mialb.dns_name
}

output "bbdd_dns" {
  value = aws_db_instance.primaria.endpoint

}

output "cloudfront_url" {

  value = aws_cloudfront_distribution.distri_cf.domain_name

}
output "bucketS3" {

  value = aws_s3_bucket.micubo.bucket_domain_name

}

# Obtener información del Auto Scaling Group
data "aws_autoscaling_group" "mi_asg" {
  name = aws_autoscaling_group.miASG.name  # Cambia esto por el nombre de tu ASG
  depends_on = [ aws_autoscaling_group.miASG ]
}

# Obtener IDs de las instancias en el ASG
data "aws_instances" "asg_instances" {
  instance_tags = {
    "aws:autoscaling:groupName" = data.aws_autoscaling_group.mi_asg.name
  }
  depends_on = [ aws_autoscaling_group.miASG ]
}

# Obtener el ID de la instancia RDS
data "aws_db_instance" "mi_rds" {
  db_instance_identifier = "postgresql"  
  depends_on = [ aws_db_instance.primaria ]
}

data "aws_ec2_managed_prefix_list" "cloudfront_prefix_list" {                      
  name = "com.amazonaws.global.cloudfront.origin-facing"                           
}  
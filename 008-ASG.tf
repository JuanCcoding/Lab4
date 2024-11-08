#En este modulo definimos los recursos para crear nuestra plantilla de lanzamiento y el ASG
#le indicamos una politica de escalado simple basado en metricas de uso de CPU
#nuestra launch template tendra todo lo necesario para acceder a las instancias (rol-ssm)
#script de arranque para montar el efs
#sustituir la contraseña de la rds en el wp-config.php y poder establecer conexion



resource "aws_launch_template" "mi_plantilla" {
  name          = "miPlantilla"
  description   = "Plantilla de EC2 para mi ASG"
  image_id = var.ami_id
  #image_id      = "ami-077a85ddaeccb242d" 
  instance_type = "t2.micro"


  iam_instance_profile {
    name = "sesionmanager"
  }

  monitoring {
    enabled = true
  }
  network_interfaces {
    associate_public_ip_address = false # revisar a quitar para probar ip privada
    security_groups             = ["${aws_security_group.SG_ec2.id}"]
  }

  tag_specifications {
    resource_type = "instance"

     tags = {
        "Name" = "${var.proyecto}-Plantilla de lanzamiento"
        "Environment" = var.env
        "Owner" = var.tagowner
  }
 
  }


  user_data = base64encode(data.template_file.user_data.rendered)


  depends_on = [aws_security_group.SG_ec2, aws_efs_file_system.miefs, aws_efs_access_point.puntoDeAcesso, aws_efs_mount_target.destinoEFS1]
}

resource "aws_autoscaling_group" "miASG" {
  name             = "Mi grupo de Auto Escalado"
  min_size         = 2
  max_size         = 3
  desired_capacity = 2
  vpc_zone_identifier       = [aws_subnet.private1.id, aws_subnet.private2.id]
  target_group_arns         = [aws_lb_target_group.mitargetgroup.arn] #en lugar de load_balancer
  health_check_type         = "EC2"
  health_check_grace_period = 300
  launch_template {
    id      = aws_launch_template.mi_plantilla.id
    version = aws_launch_template.mi_plantilla.latest_version
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = [/*"launch_template",*/ "desired_capacity"] # You can add any argument from ASG here, if those has changes, ASG Instance Refresh will trigger
  }
  tag {
    key                 = "Owners"
    value               = "Web-Team"
    propagate_at_launch = true
  }
  enabled_metrics = [
    "GroupDesiredCapacity",
    "GroupInServiceCapacity",
    "GroupPendingCapacity",
    "GroupMinSize",
    "GroupMaxSize",
    "GroupInServiceInstances",
    "GroupPendingInstances",
    "GroupStandbyInstances",
    "GroupStandbyCapacity",
    "GroupTerminatingCapacity",
    "GroupTerminatingInstances",
    "GroupTotalCapacity",
    "GroupTotalInstances",
    "GroupAndWarmPoolDesiredCapacity",
    "GroupAndWarmPoolTotalCapacity",
    "WarmPoolDesiredCapacity",
    "WarmPoolMinSize",
    "WarmPoolPendingCapacity",
    "WarmPoolTerminatingCapacity",
    "WarmPoolTotalCapacity",
    "WarmPoolWarmedCapacity"
  ]
}



resource "aws_autoscaling_policy" "ASG_CPU" {
  name                      = "avg-cpu-policy-greater-than-xx"
  policy_type               = "TargetTrackingScaling" # Important Note: The policy type, either "SimpleScaling", "StepScaling" or "TargetTrackingScaling". If this value isn't provided, AWS will default to "SimpleScaling."    
  autoscaling_group_name    = aws_autoscaling_group.miASG.name
  estimated_instance_warmup = 180 # defaults to ASG default cooldown 300 seconds if not set
  # CPU Utilization is above 50
  target_tracking_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ASGAverageCPUUtilization"
    }
    target_value = 50.0
  }

}



resource "aws_autoscaling_policy" "scale_out_one" {
  name                   = "add_one_unit_policy"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.miASG.name
}

resource "aws_autoscaling_policy" "scale_in_one" {
  name                   = "delete_one_unit_policy"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.miASG.name
}

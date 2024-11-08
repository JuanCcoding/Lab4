#Creamos un dashboard de cloudwatchs que nos muestre de forma grafica la parametrización de nuestros recursos
#tambien creamos un par de alarmas que nos alerten cuando le lanza una nueva instancia o se retira

resource "aws_cloudwatch_dashboard" "midashboard" {
  dashboard_name = "cloudwatch-dashboard"

  dashboard_body = jsonencode({
    widgets = [
      {
        "type": "metric",
        "x": 0,
        "y": 0,
        "width": 6,
        "height": 6,
        "properties": {
          "metrics": [
            [ "AWS/EC2", "CPUUtilization", "InstanceId", "mi-instance-id" ]
          ],
          "title": "CPU Utilization",
          "stat": "Average",
          "period": 300,
          "region": "us-east-1"
        }
      },
      {
        "type": "metric",
        "x": 6,
        "y": 0,
        "width": 6,
        "height": 6,
        "properties": {
          "metrics": [
            [ "AWS/EC2", "StatusCheckFailed", "InstanceId", "mis instancias" ]
          ],
          "title": "Instance Status",
          "stat": "Sum",
          "period": 300,
          "region": "us-east-1"
        }
      },
      {
        "type": "metric",
        "x": 0,
        "y": 6,
        "width": 12,
        "height": 6,
        "properties": {
          "metrics": [
            [ "AWS/ApplicationELB", "TargetResponseTime", "LoadBalancer", "${aws_lb.mialb.id}" ]
          ],
          "title": "Latency",
          "stat": "Average",
          "period": 60,
          "region": "us-east-1"
        }
      }
    ]
  })
}


#aqui creamos un par de alarmas creadas para alertar, 1- cuando una instancia usa mas del 50% de su cpu, desencadenando un evento de nuestro ASG
# 2- cuando las instancias usan menos del 20% de su cpu en caso de haber mas de 2, retira una Ec2 del ASG

resource "aws_cloudwatch_metric_alarm" "cpuover50" {
  alarm_name                = "cpuover50"
  comparison_operator       = "GreaterThanThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "30"
  statistic                 = "Average"
  threshold                 = "50"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  alarm_actions     = [aws_autoscaling_policy.scale_out_one.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpuunder20" {
  alarm_name                = "cpuunder20"
  comparison_operator       = "LessThanOrEqualToThreshold"
  evaluation_periods        = "2"
  metric_name               = "CPUUtilization"
  namespace                 = "AWS/EC2"
  period                    = "60"
  statistic                 = "Average"
  threshold                 = "20"
  alarm_description         = "This metric monitors ec2 cpu utilization"
  insufficient_data_actions = []
  alarm_actions     = [aws_autoscaling_policy.scale_in_one.arn]
}
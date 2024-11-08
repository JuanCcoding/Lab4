#awui simplemente creamos nuestro rol que permite a las EC2 de nuestro ASG poder conectarse por SSM

resource "aws_iam_role" "sesionmanager" {
  name               = "sesionmanager"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
  tags = {
    tag-key = "Rol-SSm"
  }
}

resource "aws_iam_policy_attachment" "attach_amazon_ssm_full_access-sesionmanager" {
  name       = "attach-amazon-ssm-full-access-sesionmanager"
  roles      = [aws_iam_role.sesionmanager.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMFullAccess"
}
resource "aws_iam_policy_attachment" "attach_amazon_ec2_role_for_ssm-sesionmanager" {
  name       = "attach-amazon-ec2-role-for-ssm-sesionmanager"
  roles      = [aws_iam_role.sesionmanager.name]
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2RoleforSSM" 
}

resource "aws_iam_instance_profile" "sesionmanager" {
  name = "sesionmanager"
  role = aws_iam_role.sesionmanager.name
}
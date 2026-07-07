data "aws_ami" "myami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm*"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

resource "aws_launch_template" "web_lt" {
  name = "Web_Launch_Template"

  block_device_mappings {
    device_name = "/dev/sdf"

    ebs {
      volume_size = 8
    }
  }

  iam_instance_profile {
    name = var.instance_profile_name
  }

  image_id      = data.aws_ami.myami.id
  instance_type = var.instance_type

  monitoring {
    enabled = true
  }

  vpc_security_group_ids = [var.web_sg_id]

  user_data = filebase64("${path.module}/script.sh")

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "Web_App_Tier"
    }
  }
}

resource "aws_autoscaling_group" "web_asg" {
  desired_capacity    = var.desired_capacity
  max_size            = var.max_size
  min_size            = var.min_size
  vpc_zone_identifier = var.private_subnet_ids

  launch_template {
    id      = aws_launch_template.web_lt.id
    version = "$Latest"
  }

  # Use ELB health checks so unhealthy targets behind the ALB get replaced
  health_check_type = "ELB"
  target_group_arns = [var.target_group_arn]

  tag {
    key                 = "Name"
    value               = "Web_App_Tier"
    propagate_at_launch = true
  }
}

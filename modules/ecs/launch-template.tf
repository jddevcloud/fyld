data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-ecs*arm64*"]
  }
}

resource "aws_launch_template" "ecs-launch-template" {
  image_id                    = data.aws_ami.ecs_ami.image_id
  instance_type               = var.ecs_instance_type
  vpc_security_group_ids      = [aws_security_group.instance.id, var.database_security_group, var.elastiache_security_group]
  update_default_version      = true

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs-instance-profile.name
  }

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
  }

  block_device_mappings {
    device_name = "/dev/sda1"

    ebs {
      volume_size           = 50
      delete_on_termination = true
      encrypted             = true
    }
  }

  key_name                    = "sitestream"
  user_data                   =  base64encode(templatefile("${path.module}/ecs_user_data.sh", {
                                    aws_ecs_cluster = aws_ecs_cluster.main.id
                                  }))
}

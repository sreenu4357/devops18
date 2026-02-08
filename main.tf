  resourcresource "aws_launch_template" "web_server_lt" {
  name_prefix   = "web-server-lt-"
  image_id      = "ami-0532be01f26a3de55"
  instance_type = "t3.small"
  key_name      = "docker1"

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [aws_security_group.web_server.id]
  }

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "web-server"
    }
  }
}
resource "aws_elb" "web_server_lb"{
     name = "web-server-lb"
     security_groups = [aws_security_group.web_server.id]
     subnets = ["subnet-0deebf104e2c5f5b6", "subnet-042db347b997baee5"]
     listener {
      instance_port     = 8000
      instance_protocol = "http"
      lb_port           = 80
      lb_protocol       = "http"
    }
    tags = {
      Name = "terraform-elb"
    }
  }
resource "aws_autoscaling_group" "web_server_asg" {
    name                 = "web-server-asg"
    launch_configuration = aws_launch_configuration.web_server_lt.name
    min_size             = 1
    max_size             = 3
    desired_capacity     = 2
    health_check_type    = "EC2"
    load_balancers       = [aws_elb.web_server_lb.name]
    availability_zones    = ["us-east-1a", "us-east-1f"] 
    
  }


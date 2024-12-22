provider "aws" {
  region = "us-west-1"
}
resource "aws_instance" "my_instance" {
  ami           = "ami-0aa117785d1c1bfe5" # Use the appropriate AMI ID
  instance_type = "t2.micro"
  key_name      = "devops-practice"
  tags = {
  Name = "terraform-instance"
  }
}

resource "aws_autoscaling_group" "asg" {
  desired_capacity     = 2
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier  = ["subnet-085b9ec1e84fce792"] # Replace with your subnet ID
  #launch_configuration = aws_launch_configuration.lc.id
  launch_template {
    id = aws_launch_template.lt.id
    version = "$Latest"
  }
}

resource "aws_launch_template" "lt" {
  image_id      = "ami-0aa117785d1c1bfe5"
  instance_type = "t2.micro"
  key_name      = "devops-practice"
}

resource "aws_lb" "my_lb" {
  name               = "my-load-balancer"
  internal           = false
  load_balancer_type = "application"
  subnets            = ["subnet-0eb88307a010903be", "subnet-085b9ec1e84fce792"]
}

resource "aws_route53_record" "dns" {
  zone_id = "Z0275611L41RM2FMD8UN" # Replace with your Route 53 hosted zone ID
  name    = "samsor_aditya50.com"
  type    = "A"

  alias {
    name                   = aws_lb.my_lb.dns_name
    zone_id                = aws_lb.my_lb.zone_id
    evaluate_target_health = false
  }
}

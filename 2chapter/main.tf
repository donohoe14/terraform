#### test
provider "aws" {
  region = "us-east-1"
}


resource "aws_launch_configuration" "example" {
  image_id            = "ami-0aa2b7722dc1b5612"
  instance_type       = "t2.micro"
  vpc_security_groups = [aws_security_group.instance.id]

  user_data = <<-EOF
#!/bin/bash
echo "Hello, world" > index.html
nohup busybox httpd -f -p ${var.server_port} &
EOF

  tags = {
    Name = "terraform-example"
  }
}

lifecycle {
    create_before_destroy = true
}

resource "aws_autoscaling_group" "name" {
  launch_configuration = aws_launch_configuration.example.name

  min_size = 2
  max_size = 10

  tag {
    key                 = name
    value               = "terraform-asg-example"
    propagate_at_launch = true
  }

}

resource "aws_security_group" "instance" {
  name = "terraform_example_instance"

  ingress {
    from_port   = var.server_port
    to_port     = var.server_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

variable "server_port" {
  description = "the [port the server will use for http requests]"
  type        = number
  default     = 8080
}

output "public_ip" {
  value       = aws_instance.example.public_ip
  description = "the public ip of the web server"
}






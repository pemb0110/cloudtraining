# Configure the AWS Provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0" # Or latest
    }
  }
}

provider "aws" {
  region = "eu-west-2" # Replace with your desired region
}


# Create a security group to allow HTTP access
resource "aws_security_group" "web_sg" {
  name        = "allow_http"
  description = "Allow HTTP inbound traffic"

 ingress {
    description      = "HTTP from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"] #  Open to the world - consider restricting in production
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "all"
    cidr_blocks      = ["0.0.0.0/0"]
  }
}

# Create an EC2 instance
resource "aws_instance" "web_server" {
  ami           = "ami-0fc32db49bc3bfbb1" # Amazon Linux 2 AMI (replace with your preferred AMI) - Always use latest
  instance_type = "t2.micro" # Replace with your desired instance type

  # Add user data to install a web server and create the "Hello, World!" page
  user_data = <<-EOF
#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "<html><body><h1>Hello, World!</h1></body></html>" > /var/www/html/index.html
  EOF

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
    Name = "web-server-instance"
  }
}


# Output the public IP address of the instance
output "public_ip" {
  value = aws_instance.web_server.public_ip
}

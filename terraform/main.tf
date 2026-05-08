provider "aws" {
  region = "ap-south-1"
}

resource "aws_security_group" "app_sg" {
  name = "app-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami                    = "ami-0f58b397bc5c1f2e8"
  instance_type          = "m7i-flex.large"
  key_name               = "devops-key"
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  tags = {
    Name = "DevOps-App-Server"
  }
}

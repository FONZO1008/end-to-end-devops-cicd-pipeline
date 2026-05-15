# -------------------------------------------------------
# BEFORE RUNNING:
# 1. Create an S3 bucket for state:     aws s3 mb s3://your-tf-state-bucket --region ap-south-1
# 2. Create DynamoDB table for locking: aws dynamodb create-table \
#      --table-name terraform-state-lock \
#      --attribute-definitions AttributeName=LockID,AttributeType=S \
#      --key-schema AttributeName=LockID,KeyType=HASH \
#      --billing-mode PAY_PER_REQUEST \
#      --region ap-south-1
# 3. Replace bucket name below with your actual bucket name
# -------------------------------------------------------

terraform {
  backend "s3" {
    bucket         = "your-tf-state-bucket"       # <-- Replace this
    key            = "devops-pipeline/terraform.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }
}

provider "aws" {
  region = "ap-south-1"
}

# -------------------------------------------------------
# ECR Repository
# -------------------------------------------------------
resource "aws_ecr_repository" "app" {
  name                 = "my-app"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

# -------------------------------------------------------
# IAM Role — allows EC2 to pull from ECR
# -------------------------------------------------------
resource "aws_iam_role" "ec2_ecr_role" {
  name = "ec2-ecr-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = { Service = "ec2.amazonaws.com" }
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecr_read" {
  role       = aws_iam_role.ec2_ecr_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2-ecr-profile"
  role = aws_iam_role.ec2_ecr_role.name
}

# -------------------------------------------------------
# Security Group
# -------------------------------------------------------
resource "aws_security_group" "app_sg" {
  name = "app-sg"

  # SSH restricted to your Jenkins server IP only
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.ssh_allowed_cidr]
  }

  # App port open to public
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

# -------------------------------------------------------
# EC2 Instance
# -------------------------------------------------------
resource "aws_instance" "app_server" {
  ami                    = "ami-03f4878755434977f"
  instance_type          = "t3.micro"
  key_name               = "devops-key"
  vpc_security_group_ids = [aws_security_group.app_sg.id]
  iam_instance_profile   = aws_iam_instance_profile.ec2_profile.name

  tags = {
    Name = "DevOps-App-Server"
  }
}

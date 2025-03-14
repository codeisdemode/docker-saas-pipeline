provider "aws" {
  region = var.aws_region
}

# Create a VPC for our infrastructure
resource "aws_vpc" "saas_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "saas-vpc"
  }
}

# Create public subnets in multiple availability zones
resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.saas_vpc.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "saas-public-subnet-${count.index + 1}"
  }
}

# Create private subnets in multiple availability zones
resource "aws_subnet" "private_subnets" {
  count                   = length(var.private_subnet_cidrs)
  vpc_id                  = aws_vpc.saas_vpc.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = false

  tags = {
    Name = "saas-private-subnet-${count.index + 1}"
  }
}

# Create Internet Gateway for public subnets
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.saas_vpc.id

  tags = {
    Name = "saas-igw"
  }
}

# Create route table for public subnets
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.saas_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "saas-public-route-table"
  }
}

# Associate public subnets with the public route table
resource "aws_route_table_association" "public_subnet_associations" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat_eip" {
  vpc = true

  tags = {
    Name = "saas-nat-eip"
  }
}

# Create NAT Gateway for private subnets
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnets[0].id

  tags = {
    Name = "saas-nat-gateway"
  }
}

# Create route table for private subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.saas_vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "saas-private-route-table"
  }
}

# Associate private subnets with the private route table
resource "aws_route_table_association" "private_subnet_associations" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table.id
}

# Create security group for EC2 instances
resource "aws_security_group" "ec2_sg" {
  name        = "saas-ec2-sg"
  description = "Security group for SaaS application EC2 instances"
  vpc_id      = aws_vpc.saas_vpc.id

  # Allow HTTP/HTTPS traffic from ALB
  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  # Allow SSH access from specific IPs
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidrs
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "saas-ec2-sg"
  }
}

# Create security group for ALB
resource "aws_security_group" "alb_sg" {
  name        = "saas-alb-sg"
  description = "Security group for SaaS application load balancer"
  vpc_id      = aws_vpc.saas_vpc.id

  # Allow HTTP/HTTPS traffic from internet
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "saas-alb-sg"
  }
}

# Create ECR repository
resource "aws_ecr_repository" "app_repository" {
  name                 = var.ecr_repository_name
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }

  tags = {
    Name = var.ecr_repository_name
  }
}

# Create IAM role for EC2 instances
resource "aws_iam_role" "ec2_role" {
  name = "saas-ec2-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

# Attach policy to IAM role for ECR access
resource "aws_iam_role_policy_attachment" "ecr_policy_attachment" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECR-FullAccess"
}

# Create IAM instance profile
resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "saas-ec2-instance-profile"
  role = aws_iam_role.ec2_role.name
}

# Create ALB
resource "aws_lb" "saas_alb" {
  name               = "saas-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = aws_subnet.public_subnets[*].id

  enable_deletion_protection = false

  tags = {
    Name = "saas-alb"
  }
}

# Create ALB target group
resource "aws_lb_target_group" "saas_target_group" {
  name     = "saas-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.saas_vpc.id

  health_check {
    path                = "/"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
    interval            = 30
    matcher             = "200-399"
  }

  tags = {
    Name = "saas-target-group"
  }
}

# Create ALB listener
resource "aws_lb_listener" "saas_http_listener" {
  load_balancer_arn = aws_lb.saas_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.saas_target_group.arn
  }
}

# Create customer-specific EC2 instance launch template
resource "aws_launch_template" "customer_launch_template" {
  name          = "saas-customer-launch-template"
  image_id      = var.ami_id
  instance_type = var.instance_type

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_instance_profile.name
  }

  network_interfaces {
    associate_public_ip_address = false
    security_groups             = [aws_security_group.ec2_sg.id]
  }

  user_data = base64encode(<<-EOF
    #!/bin/bash
    # Install Docker
    amazon-linux-extras install docker -y
    systemctl start docker
    systemctl enable docker

    # Install AWS CLI
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install

    # Login to ECR
    aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${data.aws_caller_identity.current.account_id}.dkr.ecr.${var.aws_region}.amazonaws.com

    # Pull the latest image
    docker pull ${aws_ecr_repository.app_repository.repository_url}:latest

    # Run the container
    docker run -d -p 80:80 -e CUSTOMER_ID=${var.customer_id} ${aws_ecr_repository.app_repository.repository_url}:latest
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "saas-customer-instance"
    }
  }

  tags = {
    Name = "saas-customer-launch-template"
  }
}

# Data source to get AWS account ID
data "aws_caller_identity" "current" {}

# Create customer module for each customer
module "customer_instance" {
  source  = "./modules/customer"
  count   = length(var.customer_ids)
  
  customer_id         = var.customer_ids[count.index]
  vpc_id              = aws_vpc.saas_vpc.id
  subnet_ids          = aws_subnet.private_subnets[*].id
  security_group_id   = aws_security_group.ec2_sg.id
  launch_template_id  = aws_launch_template.customer_launch_template.id
  aws_region          = var.aws_region
  ecr_repository_url  = aws_ecr_repository.app_repository.repository_url
  target_group_arn    = aws_lb_target_group.saas_target_group.arn
  instance_profile_name = aws_iam_instance_profile.ec2_instance_profile.name
}

# Output the ALB DNS name
output "alb_dns_name" {
  value = aws_lb.saas_alb.dns_name
}

# Output the ECR repository URL
output "ecr_repository_url" {
  value = aws_ecr_repository.app_repository.repository_url
} 
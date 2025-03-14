# Customer module to create customer-specific resources

resource "aws_instance" "customer_instance" {
  ami                  = data.aws_launch_template.customer_template.image_id
  instance_type        = data.aws_launch_template.customer_template.instance_type
  subnet_id            = var.subnet_ids[0]
  vpc_security_group_ids = [var.security_group_id]
  iam_instance_profile = var.instance_profile_name
  
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
    aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin ${var.ecr_repository_url}

    # Pull the latest image
    docker pull ${var.ecr_repository_url}:latest

    # Run the container with customer-specific environment
    docker run -d -p 80:80 \
      -e CUSTOMER_ID=${var.customer_id} \
      -e CUSTOMER_DOMAIN=${var.customer_id}.example.com \
      -e CUSTOMER_DB_NAME=${var.customer_id} \
      -v /data/${var.customer_id}:/app/data \
      --name customer-${var.customer_id} \
      --restart always \
      ${var.ecr_repository_url}:latest
  EOF
  )

  tags = {
    Name        = "customer-${var.customer_id}-instance"
    Customer    = var.customer_id
    Environment = var.environment
    Managed     = "terraform"
  }

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
    encrypted   = true
    tags = {
      Name     = "customer-${var.customer_id}-volume"
      Customer = var.customer_id
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

# Register the instance with the ALB target group
resource "aws_lb_target_group_attachment" "customer_tg_attachment" {
  target_group_arn = var.target_group_arn
  target_id        = aws_instance.customer_instance.id
  port             = 80
}

# Create Route53 record for customer domain
resource "aws_route53_record" "customer_domain" {
  count   = var.create_dns_record ? 1 : 0
  zone_id = var.route53_zone_id
  name    = "${var.customer_id}.${var.dns_domain}"
  type    = "A"

  alias {
    name                   = var.alb_dns_name
    zone_id                = var.alb_zone_id
    evaluate_target_health = true
  }
}

# Data source to get launch template details
data "aws_launch_template" "customer_template" {
  id = var.launch_template_id
}

# Create customer-specific CloudWatch alarms
resource "aws_cloudwatch_metric_alarm" "customer_cpu_alarm" {
  alarm_name          = "customer-${var.customer_id}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors EC2 CPU utilization for customer ${var.customer_id}"
  
  dimensions = {
    InstanceId = aws_instance.customer_instance.id
  }
  
  alarm_actions = var.alarm_actions
}

resource "aws_cloudwatch_metric_alarm" "customer_memory_alarm" {
  alarm_name          = "customer-${var.customer_id}-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "CWAgent"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  alarm_description   = "This metric monitors EC2 memory utilization for customer ${var.customer_id}"
  
  dimensions = {
    InstanceId = aws_instance.customer_instance.id
  }
  
  alarm_actions = var.alarm_actions
}

# Output the customer instance ID
output "instance_id" {
  value = aws_instance.customer_instance.id
}

# Output the customer instance private IP
output "private_ip" {
  value = aws_instance.customer_instance.private_ip
}

# Output the customer domain
output "customer_domain" {
  value = var.create_dns_record ? aws_route53_record.customer_domain[0].fqdn : null
} 
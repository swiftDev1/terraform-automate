#VPC and Subnet
data "aws_vpc" "default-vpc" {
  default = true
}

data "aws_subnets" "subnets" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default-vpc.id]
  }
}

data "aws_subnet" "unit-subnets" {
  for_each = toset(data.aws_subnets.subnets.ids)
  id       = each.value
}

# output "subnet_ids" {
#   value = [for s in data.aws_subnet.example : s.id]
# }

#Security Groups
resource "aws_security_group" "web-server-sg" {
  name = "web-server-sg"
}

resource "aws_vpc_security_group_ingress_rule" "web-server-sgrule" {
  security_group_id = aws_security_group.web-server-sg.id

  from_port   = 8080
  to_port     = 8080
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_security_group" "alb-sg" {
  name = "alb-sg"
}

resource "aws_vpc_security_group_ingress_rule" "alb-ingress-rule" {
  security_group_id = aws_security_group.alb-sg.id

  from_port   = 80
  to_port     = 80
  ip_protocol = "tcp"
  cidr_ipv4   = "0.0.0.0/0"
}

resource "aws_vpc_security_group_egress_rule" "alb-egress-rule" {
  security_group_id = aws_security_group.alb-sg.id

  cidr_ipv4   = "0.0.0.0/0"
  ip_protocol = "-1"
#   from_port   = 0
#   to_port     = 0
}

# EC2 Instances
resource "aws_instance" "instance_1" {
  ami             = "ami-011899242bb902164" # Ubuntu 20.04 LTS // us-east-1
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web-server-sg.name]
  user_data       = <<-EOF
              #!/bin/bash
              echo "Hello, World From Server 1" > index.html
              python3 -m http.server 8080 &
              EOF

  tags = {
    "Name" = "Server 1"
  }
}

resource "aws_instance" "instance_2" {
  ami             = "ami-011899242bb902164" # Ubuntu 20.04 LTS // us-east-1
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.web-server-sg.name]
  user_data       = <<-EOF
              #!/bin/bash
              echo "Hello, World From Server 2" > index.html
              python3 -m http.server 8080 &
              EOF

  tags = {
    "Name" = "Server 2"
  }
}

#Load Balancer Resources
resource "aws_lb" "webserver-lb" {
  name               = "webserver-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb-sg.id]
#   subnets            = [for subnet in data.aws_subnet.unit-subnets : subnet.id] still take a good look at this problem
  subnets = ["subnet-0e3d525d09165c241", "subnet-0644ec84333d51042"]
  enable_deletion_protection = false

}

resource "aws_lb_target_group" "instance-target-group" {
  name     = "instance-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default-vpc.id
}

resource "aws_lb_target_group_attachment" "instance-attachment1" {
  target_group_arn = aws_lb_target_group.instance-target-group.arn
  target_id        = aws_instance.instance_1.id
  port             = 8080
}

resource "aws_lb_target_group_attachment" "instance-attachment2" {
  target_group_arn = aws_lb_target_group.instance-target-group.arn
  target_id        = aws_instance.instance_2.id
  port             = 8080
}

resource "aws_lb_listener" "front_end" {
  load_balancer_arn = aws_lb.webserver-lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.instance-target-group.arn
  }
}


# resource "aws_lb_listener_rule" "static" {
#   listener_arn = aws_lb_listener.front_end.arn
#   priority     = 100

#   action {
#     type             = "forward"
#     target_group_arn = aws_lb_target_group.instance-target-group.arn
#   }

#   condition {
#     path_pattern {
#       values = ["*"]
#     }
#   }

# }

#Create Route53 Resources
resource "aws_route53_zone" "primary" {
  name = "paramentora.com"
}

resource "aws_route53_record" "www" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "paramentora.com"
  type    = "A"

  alias {
    name                   = aws_lb.webserver-lb.dns_name
    zone_id                = aws_lb.webserver-lb.zone_id
    evaluate_target_health = true
  }

  depends_on = [ aws_route53_zone.primary ]
}

#Create S3 bucket for web-data with versioning and encryption enabled
resource "aws_s3_bucket" "web-data-bucket" {
  bucket_prefix = "web-data-bucket"
  force_destroy = true

  tags = {
    Name        = "web-data bucket"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "web-data-sse" {
  bucket = aws_s3_bucket.web-data-bucket.id

  rule {
    apply_server_side_encryption_by_default {
     
      sse_algorithm     = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "web-data-bucket-versioning" {
  bucket = aws_s3_bucket.web-data-bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

#Create Database Instance
resource "aws_db_instance" "db_instance" {
  allocated_storage = 20
  # This allows any minor version within the major engine_version
  # defined below, but will also result in allowing AWS to auto
  # upgrade the minor version of your DB. This may be too risky
  # in a real production environment.
  auto_minor_version_upgrade = true
  storage_type               = "standard"
  engine                     = "postgres"
  engine_version             = "12"
  instance_class             = "db.t2.micro"
  db_name                    = "mydb"
  username                   = "foo"
  password                   = "foobarbaz"
  skip_final_snapshot        = true
}
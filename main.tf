data "aws_vpc" "default-vpc" {
  id = "vpc-0380a6b686c64a08d"
}

data "aws_subnet" "private-subnet" {
  id = "subnet-0e3d525d09165c241"
}

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
  from_port   = 0
  to_port     = 0
  ip_protocol = "-1"
}


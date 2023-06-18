data "aws_vpc" "default-vpc" {
  id = "vpc-0380a6b686c64a08d"
}

data "aws_subnet" "private-subnet" {
  id = "subnet-0e3d525d09165c241"
}

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web-server" {
  ami           = data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  associate_public_ip_address = false
  subnet_id = data.aws_subnet.private-subnet.id

  tags = {
    Name = "HelloWorld"
  }
}
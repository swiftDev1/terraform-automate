#General Variables
variable "default_region" {
  description = "default region for the provider to deploy resources"
  type = string
  default = "us-east-1"
}

#EC2 Variables
variable "ami" {
    description = "Amazon machine Image to be used to deploy ec2 instances"
    type = string
    default = "ami-011899242bb902164" # Ubuntu 20.04 LTS // us-east-1  
}

variable "instance_type" {
  description = "EC2 instance type "
  type = string
  default = "t2.micro"
}

#Route53 Variables
variable "domain" {
  description = "domain name for website"
  type = string
}

#S3 Variables
variable "bucket_prefix" {
  description = "prefix to be appended to bucket before a random unique integer is attached"
  type = string
}

#RDS Variables
variable "db_name" {
  description = "name of the DB"
  type = string
}

variable "db_username" {
  description = "username for the DB"
  type = string
}

variable "db_pass" {
  description = "Password for the database"
  type = string
  sensitive = true
}
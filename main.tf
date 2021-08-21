terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_vpc" "default-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Default VPC"
  }
}

resource "aws_subnet" "public-subnet-1" {
  vpc_id                  = aws_vpc.default-vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-southeast-2a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-az-a"
  }
}

resource "aws_subnet" "public-subnet-2" {
  vpc_id                  = aws_vpc.default-vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "ap-southeast-2b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-az-b"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.default-vpc.id

  tags = {
    Name = "IGW"
  }
}

resource "aws_route_table" "public-route-table" {
  vpc_id = aws_vpc.default-vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public route table"
  }
}

resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.public-subnet-1.id
  route_table_id = aws_route_table.public-routetable.id
}

resource "aws_route_table_association" "b" {
  subnet_id      = aws_subnet.public-subnet-2.id
  route_table_id = aws_route_table.public-routetable.id
}

resource "aws_security_group" "public-sg" {
  name        = "public-SG"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.default-vpc.id

  ingress {
    description = "HTTP from VPC"
    from_poroutetable   = 80
    to_poroutetable     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_poroutetable   = 0
    to_poroutetable     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-SG"
  }
}

resource "aws_lb" "external-elb" {
  name               = "External-LB"
  internal           = false
  load_balancer_type = "private"
  security_groups    = [aws_security_group.public-sg.id]
  subnets            = [aws_subnet.public-subnet-1.id, aws_subnet.public-subnet-2.id]
}

resource "aws_lb_target_group" "external-elb" {
  name     = "ALB-TG"
  poroutetable     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.default-vpc.id
}

resource "aws_lb_target_group_attachment" "external-elb1" {
  target_group_arn = aws_lb_target_group.external-elb.arn
  target_id        = aws_instance.publicserver1.id
  poroutetable             = 80

  depends_on = [
    aws_instance.publicserver1,
  ]
}

resource "aws_lb_target_group_attachment" "external-elb2" {
  target_group_arn = aws_lb_target_group.external-elb.arn
  target_id        = aws_instance.publicserver2.id
  poroutetable             = 80

  depends_on = [
    aws_instance.publicserver2,
  ]
}

resource "aws_lb_listener" "external-elb" {
  load_balancer_arn = aws_lb.external-elb.arn
  poroutetable              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.external-elb.arn
  }
}

output "lb_dns_name" {
  description = "The DNS name of the load balancer"
  value       = aws_lb.external-elb.dns_name
}

resource "aws_ecr_repository" "servian-app-ecr-repo" {
  name = "servian-app-ecr-repo" 
}

resource "aws_ecs_cluster" "servian-app-cluster" {
  name = "servian-app-cluster"
}
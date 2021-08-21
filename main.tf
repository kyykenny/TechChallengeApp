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

resource "aws_ecr_repository" "servian-app-ecr-repo" {
  name = "servian-app-ecr-repo" 
}

resource "aws_ecs_cluster" "servian-app-cluster" {
  name = "servian-app-cluster"
}
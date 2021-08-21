terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
}

provider "aws" {
  profile = "default"
  aws_access_key_id = "AKIA3S77G6S2KFH2ARVX"
  aws_secret_access_key = "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"
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

resource "aws_ecr_repository" "servian-app-ecr-repo" {
  name = "servian-app-ecr-repo" 
}

resource "aws_ecs_cluster" "servian-app-cluster" {
  name = "servian-app-cluster"
}
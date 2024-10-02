terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.67.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
  access_key = "AKIA5JYOYINHNSXJB4NJ"
  secret_key = "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"
}

resource "aws_vpc" "first-vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "main"
  }
}

resource "aws_subnet" "subnet-1" {
  vpc_id     = aws_vpc.first-vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "first-vpc-subnet"
  }
}
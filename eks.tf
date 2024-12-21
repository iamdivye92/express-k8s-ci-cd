provider "aws" {
  region = "ap-south-1" # Ensure the region is correct
}

# Fetch Available Availability Zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Create VPC for EKS
resource "aws_vpc" "eks_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "eks-vpc"
  }
}

# Create Internet Gateway for the VPC
resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-igw"
  }
}

# Create Route Table with Internet Gateway
resource "aws_route_table" "eks_route_table" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.eks_igw.id
  }

  tags = {
    Name = "eks-route-table"
  }
}

# Create Subnets for the VPC
resource "aws_subnet" "eks_subnets" {
  count                   = 2
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = cidrsubnet(aws_vpc.eks_vpc.cidr_block, 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "eks-subnet-${count.index}"
  }
}

# Associate Subnets with the Route Table
resource "aws_route_table_association" "eks_route_table_assoc" {
  count          = length(aws_subnet.eks_subnets)
  subnet_id      = aws_subnet.eks_subnets[count.index].id
  route_table_id = aws_route_table.eks_route_table.id
}

# Create the EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "my-eks-cluster"
  role_arn = "arn:aws:iam::975049911073:role/eks-cluster-role" # Directly use the IAM role ARN for root user

  vpc_config {
    subnet_ids = aws_subnet.eks_subnets[*].id
  }

  tags = {
    Name = "eks-cluster"
  }
}

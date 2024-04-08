# network.tf
resource "aws_vpc" "eks-cluster-vpc" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.eks-cluster-vpc.id

  tags = {
    Name = "main-ig-gateway"
  }
}

resource "aws_subnet" "private-central-1a" {
  vpc_id     = aws_vpc.eks-cluster-vpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "eu-central-1a-private"
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/eks-cluster-production" = "shared"
  }
}


resource "aws_subnet" "public-central-1b" {
  vpc_id     = aws_vpc.eks-cluster-vpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "eu-central-1b-public"
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/eks-cluster-production" = "shared"
  }
}
resource "aws_subnet" "public-central-1a" {
  vpc_id     = aws_vpc.eks-cluster-vpc.id
  cidr_block = "10.0.3.0/24"
  availability_zone = "eu-central-1a"

  tags = {
    Name = "eu-central-1a-public"
    "kubernetes.io/role/elb" = 1
    "kubernetes.io/cluster/eks-cluster-production" = "shared"
  }
}
resource "aws_subnet" "private-central-1b" {
  vpc_id     = aws_vpc.eks-cluster-vpc.id
  cidr_block = "10.0.4.0/24"
  availability_zone = "eu-central-1b"

  tags = {
    Name = "eu-central-1b-private"
    "kubernetes.io/role/internal-elb" = 1
    "kubernetes.io/cluster/eks-cluster-production" = "shared"
  }
}
# aws-provider.tf

provider "aws" {
  access_key = "my-access-key"
  secret_key = "super-secret-key"
  region = "eu-central-1"
}

provider "helm" {
  kubernetes {
    host                   = aws_eks_cluster.prod-eks-cluster.endpoint
    cluster_ca_certificate = base64decode(aws_eks_cluster.prod-eks-cluster.certificate_authority[0].data)
    exec {
      api_version = "client.authentication.k8s.io/v1beta1"
      args        = ["eks", "get-token", "--cluster-name", aws_eks_cluster.prod-eks-cluster.name]
      command     = "aws"
    }
  }
}
data "aws_eks_cluster_auth" "cluster" {
  name  = try(aws_eks_cluster.eks-cluster[0].name, "")
}

provider "kubernetes" {
  host                   = try(aws_eks_cluster.eks-cluster[0].endpoint, null)
  cluster_ca_certificate = base64decode(try(aws_eks_cluster.eks-cluster[0].certificate_authority[0].data, null))
  token                  = data.aws_eks_cluster_auth.cluster.token
  #host                   = element(concat(data.aws_eks_cluster.cluster[*].endpoint, tolist([""])), 0)
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 5.0.0"
    }
  }
}

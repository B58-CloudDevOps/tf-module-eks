resource "aws_eks_cluster" "main" {
  name                      = "${var.env}-eks"
  role_arn                  = aws_iam_role.cluster.arn
  enabled_cluster_log_types = ["audit", "controllerManager"]
  version                   = var.eks_version

  vpc_config {
    subnet_ids = var.subnet_ids # This is where nodes are going to be provisioned. This is a multi-zonal kubernetes cluster
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster-AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster-AmazonEKSVPCResourceController,
  ]
  tags = local.eks_tags
}

# Defines the retention of the enabled logs on cloud watch
resource "aws_cloudwatch_log_group" "logger" {
  name              = "/aws/eks/${var.env}-eks/logger"
  retention_in_days = 1
}

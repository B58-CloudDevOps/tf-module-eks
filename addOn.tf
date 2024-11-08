# This enables the VPC-CNI 
resource "aws_eks_addon" "vpc_cni" {
  depends_on   = [aws_eks_cluster.main]
  cluster_name = aws_eks_cluster.main.name
  addon_name   = "vpc-cni"
  configuration_values = jsonencode({
    "enableNetworkPolicy" = "true"
  })
}
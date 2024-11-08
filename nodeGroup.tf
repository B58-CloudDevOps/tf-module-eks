# Provisions Node Group and attachs this to the eks 
resource "aws_eks_node_group" "node" {
  depends_on = [aws_eks_addon.vpc_cni]

  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.key

  node_role_arn  = aws_iam_role.node.arn
  subnet_ids     = var.subnet_ids
  instance_types = each.value["instance_type"]
  capacity_type  = each.value["capacity_type"]

  scaling_config {
    desired_size = each.value["node_min_size"]
    max_size     = each.value["node_max_size"]
    min_size     = each.value["node_min_size"]
  }

  tags = {
    Environment = "Test"
    project     = "expense"
  }
}

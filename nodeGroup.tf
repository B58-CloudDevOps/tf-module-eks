# Provisions Node Group and attachs this to the eks 
resource "aws_eks_node_group" "node" {
  depends_on = [aws_eks_addon.vpc_cni]

  for_each = var.node_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.name

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



#  IAM Role for EKS Node Group
resource "aws_iam_role" "node" {
  name = "eks-node-group-example"

  assume_role_policy = jsonencode({
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
    Version = "2012-10-17"
  })
}


resource "aws_iam_role_policy_attachment" "example-AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node-example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node-example.name
}

resource "aws_iam_role_policy_attachment" "example-AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node-example.name
}

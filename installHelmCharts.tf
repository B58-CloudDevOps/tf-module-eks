resource "null_resource" "helm_install" {

  depends_on = [aws_eks_cluster.main, aws_eks_node_group.node]

  provisioner "local-exec" {
    command = <<EOF
aws eks update-kubeconfig --name "${var.env}-eks"
kubectl get nodes
EOF
  }
}
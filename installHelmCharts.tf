resource "null_resource" "helm_install_boot" {

  #   depends_on = [aws_eks_cluster.main, aws_eks_node_group.node]
  triggers = {
    always_run = timestamp() # This ensure that this provisioner would be triggering all the time
  }
  provisioner "local-exec" {
    command = <<EOF
rm -rf .kube/config
sleep 240
aws eks update-kubeconfig --name "${var.env}-eks"
kubectl get nodes
echo "Installing Metrics Server"
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
echo "Installing ArgoCD"
kubectl create ns argocd && true
sleep 30
kubectl apply -f https://raw.githubusercontent.com/B58-CloudDevOps/learn-kubernetes/refs/heads/main/arogCD/argo.yaml -n argocd 
EOF
  }
}
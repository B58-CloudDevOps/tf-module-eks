resource "null_resource" "helm_install_boot" {


  provisioner "local-exec" {
    command = <<EOF
rm -rf .kube/config
sleep 19
aws eks update-kubeconfig --name "${var.env}-eks"
kubectl get nodes
echo "Installing Metrics Server"
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
echo "Installing ArgoCD"
kubectl create ns argocd || true
sleep 10
kubectl apply -f https://raw.githubusercontent.com/B58-CloudDevOps/learn-kubernetes/refs/heads/main/arogCD/argo.yaml -n argocd 

echo "Installing Nginx Ingress Controller"
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo list 
ls -ltr
echo "${path.module}"
helm upgrade -i ngx-ingres ingress-nginx/ingress-nginx -f ${path.module}/ingress.yaml
EOF
  }
}

# Deploys filebeat
resource "null_resource" "filebeat" {

  depends_on = [aws_eks_cluster.main, aws_eks_node_group.node, null_resource.helm_install_boot]

  triggers = {
    always_run = timestamp() # This ensure that this provisioner would be triggering all the time
  }
  provisioner "local-exec" {
    on_failure = continue
    command    = <<EOF

aws eks update-kubeconfig --name "${var.env}-eks"
helm repo add elastic https://helm.elastic.co
helm upgrade -i filebeat elastic/filebeat -f  ${path.module}/filebeat.yml
EOF
  }
}

resource "null_resource" "prometheus_stack" {

  depends_on = [aws_eks_cluster.main, aws_eks_node_group.node, null_resource.helm_install_boot, null_resource.filebeat]
  provisioner "local-exec" {
    on_failure = continue
    command    = <<EOF

aws eks update-kubeconfig --name "${var.env}-eks"
kubectl get nodes
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prom-stack prometheus-community/kube-prometheus-stack -f ${path.module}/prometheus-dev.yaml || true
EOF
  }
}


# Destroy time provisioners to delete the lb
# resource "null_resource" "helm_uninstall" {

#   provisioner "local-exec" {
#     when    = destroy
#     command = <<EOF
# aws eks update-kubeconfig --name "dev-eks"
# echo "UnInstalling Nginx Ingress Controller"

# helm uninstall ngx-ingress

# EOF
#   }
# }
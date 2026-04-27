provider "helm" {
    kubernetes{
        host = aws_eks_cluster.main.endpoint
        cluster_ca_certificate = base64decode(aws_eks_cluster.main.certificate_authority[0].data)
        token                  = data.aws_eks_auth.cluster.token
    }
}

resource "helm_release" "prometheus" {
  name       = "prometheus"
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  namespace  = "monitoring"

  create_namespace = true

  set {
    name  = "prometheus.prometheusSpec.retention"
    value = "15d"  # Keep 15 days of metrics
  }
}
#########################
# Data Source: EKS
#########################
data "aws_eks_cluster" "cluster" {
  name = var.cluster_id
}

data "aws_eks_cluster_auth" "cluster" {
  name = var.cluster_id
}

#########################
# Kubernetes Provider
#########################
provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.cluster.token
}

#########################
# Helm Provider
#########################
provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.cluster.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.cluster.token
  }
}

#########################
# Helm: AWS Load Balancer Controller
#########################
resource "helm_release" "loadbalancer_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.7.1" # Optional but recommended for stability
  timeout    = 600     # Increase timeout to avoid context deadline exceeded

  set {
    name  = "clusterName"
    value = var.cluster_id
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }
}

#########################
# Namespace for Monitoring
#########################
resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = "monitoring"
  }
}

#########################
# Helm: Prometheus + Grafana
#########################
resource "helm_release" "prometheus_grafana_stack" {
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  chart            = "kube-prometheus-stack"
  version          = "58.0.0"
  namespace        = kubernetes_namespace.monitoring.metadata[0].name
  timeout          = 600
  max_history      = 5
  cleanup_on_fail  = true
  wait             = true
  wait_for_jobs    = true

  values = [
    <<-EOT
    prometheus:
      enabled: true
      prometheusSpec:
        scrapeInterval: 30s
        evaluationInterval: 30s
        resources:
          requests:
            memory: 1Gi
            cpu: 500m
      additionalPodMonitors:
        - name: aws-lb-controller-monitor
          namespaceSelector:
            matchNames: ["kube-system"]
          podMetricsEndpoints:
            - port: http
              path: /metrics
          selector:
            matchLabels:
              app.kubernetes.io/name: aws-load-balancer-controller

    grafana:
      enabled: true
      adminPassword: "admin"
      service:
        type: LoadBalancer
        annotations:
          service.beta.kubernetes.io/aws-load-balancer-type: "external"
          service.beta.kubernetes.io/aws-load-balancer-scheme: "internet-facing"
          service.beta.kubernetes.io/aws-load-balancer-nlb-target-type: "ip"
        port: 80
        targetPort: 3000
      resources:
        requests:
          memory: 512Mi
          cpu: 300m
    EOT
  ]

  depends_on = [
    helm_release.loadbalancer_controller,
    kubernetes_namespace.monitoring
  ]
}

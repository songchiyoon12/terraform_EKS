
resource "helm_release" "karpenter" {
  name       = "karpenter"
  namespace  = "kube-system"
  repository = "oci://public.ecr.aws/karpenter"
  version    = "1.4.0"
  chart      = "karpenter"

  repository_username = data.aws_ecrpublic_authorization_token.token.user_name
  repository_password = data.aws_ecrpublic_authorization_token.token.password

  set {
    name  = "settings.clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/KarpenterControllerRole-${var.cluster_name}"
  }

  set {
    name  = "controller.resources.requests.cpu"
    value = "1"
  }

  set {
    name  = "controller.resources.requests.memory"
    value = "1Gi"
  }

  set {
    name  = "controller.resources.limits.cpu"
    value = "1"
  }

  set {
    name  = "controller.resources.limits.memory"
    value = "1Gi"
  }
}


resource "kubectl_manifest" "karpenter_nodepools_crd" {
  yaml_body = file("${path.module}/crd/karpenter.sh_nodepools.yaml")
}

resource "kubectl_manifest" "karpenter_ec2nodeclasses_crd" {
  yaml_body = file("${path.module}/crd/karpenter.k8s.aws_ec2nodeclasses.yaml")
}

resource "kubectl_manifest" "karpenter_nodeclaims_crd" {
  yaml_body = file("${path.module}/crd/karpenter.sh_nodeclaims.yaml")
}

resource "kubectl_manifest" "karpenter_nodepool" {
  yaml_body = <<-EOF
apiVersion: karpenter.sh/v1
kind: NodePool
metadata:
  name: default
spec:
  template:
    spec:
      requirements:
        - key: kubernetes.io/arch
          operator: In
          values: ["amd64"]
        - key: kubernetes.io/os
          operator: In
          values: ["linux"]
        - key: karpenter.sh/capacity-type
          operator: In
          values: ["on-demand"]
        - key: karpenter.k8s.aws/instance-category
          operator: In
          values: ["t"]
        - key: karpenter.k8s.aws/instance-generation
          operator: Gt
          values: ["2"]
        - key: node.kubernetes.io/instance-type
          operator: In
          values: ["t3.large"]
      nodeClassRef:
        group: karpenter.k8s.aws
        kind: EC2NodeClass
        name: default
      expireAfter: 1h
  limits:
    cpu: 9000
  disruption:
    consolidationPolicy: WhenEmptyOrUnderutilized
    consolidateAfter: 1m
EOF
}

resource "kubectl_manifest" "karpenter_nodeclass" {
  yaml_body = <<-EOF
apiVersion: karpenter.k8s.aws/v1
kind: EC2NodeClass
metadata:
  name: default
spec:
  role: "KarpenterNodeRole-${var.cluster_name}"
  amiSelectorTerms:
    - alias: "al2023@latest"
  subnetSelectorTerms:
    - tags:
        karpenter.sh/discovery: "${var.cluster_name}"
  securityGroupSelectorTerms:
    - tags:
        karpenter.sh/discovery: "${var.cluster_name}"
  metadataOptions:
    httpEndpoint: enabled
    httpProtocolIPv6: disabled
    httpPutResponseHopLimit: 2
    httpTokens: required
EOF
}
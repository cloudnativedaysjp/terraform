# ------------------------------------------------------------#
#  EKS
# ------------------------------------------------------------#
module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.5.1"

  cluster_name    = var.cluster_name
  cluster_version = var.cluster_version
  enable_irsa     = true

  # https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/eks-add-ons.html
  cluster_addons = {
    # https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/managing-coredns.html
    coredns = {
      most_recent = true
    }

    # https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/managing-kube-proxy.html
    kube-proxy = {
      most_recent = true
    }

    # https://docs.aws.amazon.com/ja_jp/eks/latest/userguide/pod-networking.html
    vpc-cni = {
      most_recent              = true
      service_account_role_arn = module.vpc_cni_irsa.iam_role_arn
      configuration_values = jsonencode({
        env = {
          # Reference docs https://docs.aws.amazon.com/eks/latest/userguide/cni-increase-ip-addresses.html
          ENABLE_PREFIX_DELEGATION = "true"
          WARM_PREFIX_TARGET       = "1"
        }
      })
    }
  }

  vpc_id                   = module.vpc.vpc_id
  subnet_ids               = module.vpc.public_subnets
  control_plane_subnet_ids = module.vpc.intra_subnets

  cluster_endpoint_public_access = true

  # Extend cluster security group rules
  cluster_security_group_additional_rules = {
    ingress_nodes_ephemeral_ports_tcp = {
      description                = "Allow managed and unmanaged nodes to communicate with each other (all ports)"
      protocol                   = "-1"
      from_port                  = 0
      to_port                    = 65535
      type                       = "ingress"
      source_node_security_group = true
    }
  }

  # Extend node-to-node security group rules
  node_security_group_additional_rules = {
    ingress_from_cluster = {
      description                   = "Allow managed and unmanaged nodes to communicate with each other (all ports)"
      protocol                      = "-1"
      from_port                     = 0
      to_port                       = 65535
      type                          = "ingress"
      source_cluster_security_group = true
    }
    ingress_self_all = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 65535
      type        = "ingress"
      self        = true
    }
    egress_node_communications = {
      description = "Node to node all ports/protocols"
      protocol    = "-1"
      from_port   = 0
      to_port     = 65535
      type        = "egress"
      self        = true
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    bottolerocket = {
      name = "dk-us-mng-spot"

      subnet_ids = module.vpc.public_subnets

      min_size     = var.node_min_size
      max_size     = var.node_max_size
      desired_size = var.node_desired_size

      platform       = "bottlerocket"
      ami_type       = "BOTTLEROCKET_x86_64"
      instance_types = ["m6i.large", "m6a.large", "m5.large", "m5a.large", "t3.large", "t3a.large"]

      # Graviton対応時にコメントアウト解除
      # ami_type = "BOTTLEROCKET_ARM_64"
      # instance_types = ["m6g.xlarge", "t4g.xlarge", "r6g.xlarge"]

      capacity_type = "SPOT"

      # We are using the IRSA created below for permissions
      # However, we have to deploy with the policy attached FIRST (when creating a fresh cluster)
      # and then turn this off after the cluster/node group is created. Without this initial policy,
      # the VPC CNI fails to assign IPs and nodes cannot join the cluster
      # See https://github.com/aws/containers-roadmap/issues/1666 for more context
      iam_role_attach_cni_policy = true

      iam_role_additional_policies = {
        additional                         = aws_iam_policy.eks_additional_policy.arn,
        AmazonEC2ContainerRegistryReadOnly = data.aws_iam_policy.AmazonEC2ContainerRegistryReadOnly.arn,
        AmazonEKSWorkerNodePolicy          = data.aws_iam_policy.AmazonEKSWorkerNodePolicy.arn,
        AmazonEKS_CNI_Policy               = data.aws_iam_policy.AmazonEKS_CNI_Policy.arn,
        AWSElementalMediaLiveFullAccess    = data.aws_iam_policy.AWSElementalMediaLiveFullAccess.arn,
        AmazonS3FullAccess                 = data.aws_iam_policy.AmazonS3FullAccess.arn,
        AmazonSESFullAccess                = data.aws_iam_policy.AmazonSESFullAccess.arn,
        AmazonSSMManagedInstanceCore       = data.aws_iam_policy.AmazonSSMManagedInstanceCore.arn,
        AmazonSQSFullAccess                = data.aws_iam_policy.AmazonSQSFullAccess.arn,
        CloudWatchAgentServerPolicy        = data.aws_iam_policy.CloudWatchAgentServerPolicy.arn,
        CloudWatchSyntheticsReadOnlyAccess = data.aws_iam_policy.CloudWatchSyntheticsReadOnlyAccess.arn,
        AWSElementalMediaPackageFullAccess = data.aws_iam_policy.AWSElementalMediaPackageFullAccess.arn
      }
    }
  }

  # aws-auth
  manage_aws_auth_configmap = true
  aws_auth_roles = [
    {
      rolearn  = module.eks.eks_managed_node_groups["bottolerocket"].iam_role_arn
      username = "system:node:{{EC2PrivateDNSName}}"
      groups = [
        "system:bootstrappers",
        "system:nodes",
      ]
    },
    {
      rolearn  = "arn:aws:iam::${var.aws_account_id}:role/AWSReservedSSO_dreamkast-core_07d1ae507f1df69c"
      username = "AWSReservedSSO_dreamkast-core_07d1ae507f1df69c:{{SessionName}}"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${var.aws_account_id}:role/AWSReservedSSO_AdministratorAccess_4f7317794a64f92f"
      username = "AWSReservedSSO_AdministratorAccess_4f7317794a64f92f:{{SessionName}}"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${var.aws_account_id}:role/AWSReservedSSO_observability-core_80f44c7b3a1a4227"
      username = "AWSReservedSSO_observability-core_80f44c7b3a1a4227:{{SessionName}}"
      groups   = ["system:masters"]
    },
    {
      rolearn  = "arn:aws:iam::${var.aws_account_id}:role/tfc-role"
      username = "tfc-role:{{SessionName}}"
      groups   = ["system:masters"]
    }
    # {
    #   rolearn  = "arn:aws:iam::${var.aws_account_id}:role/KarpenterNodeRole-dreamkast-dev-cluster"
    #   username = "system:node:{{EC2PrivateDNSName}}"
    #   groups   = ["system:boottrappers", "system:nodes"]
    # },
  ]

  aws_auth_users = var.eks_users_list

  kms_key_administrators = [
    "arn:aws:iam::${var.aws_account_id}:role/aws-reserved/sso.amazonaws.com/ap-northeast-1/AWSReservedSSO_dreamkast-core_07d1ae507f1df69c",
    "arn:aws:iam::${var.aws_account_id}:role/aws-reserved/sso.amazonaws.com/ap-northeast-1/AWSReservedSSO_AdministratorAccess_4f7317794a64f92f",
    "arn:aws:iam::${var.aws_account_id}:role/tfc-role"
  ]

  tags = { "karpenter.sh/discovery" = "${var.cluster_name}" }

}


resource "aws_iam_policy" "eks_additional_policy" {
  name = "${var.cluster_name}-additional-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      # for cert-manager
      {
        Effect   = "Allow",
        Action   = "route53:GetChange",
        Resource = "arn:aws:route53:::change/*"
      },
      {
        Effect = "Allow",
        Action = [
          "route53:ChangeResourceRecordSets",
          "route53:ListResourceRecordSets"
        ],
        Resource = "arn:aws:route53:::hostedzone/*"
      },
      {
        Effect   = "Allow",
        Action   = "route53:ListHostedZonesByName",
        Resource = "*"
      },
      # for external-secret
      {
        Effect   = "Allow",
        Action   = "secretsmanager:GetSecretValue",
        Resource = "*"
      },
      # for Amazon IVS
      {
        Effect = "Allow",
        Action = [
          "ivs:CreateChannel",
          "ivs:CreateRecordingConfiguration",
          "ivs:GetChannel",
          "ivs:GetRecordingConfiguration",
          "ivs:GetStream",
          "ivs:GetStreamKey",
          "ivs:GetStreamSession",
          "ivs:ListChannels",
          "ivs:ListRecordingConfigurations",
          "ivs:ListStreamKeys",
          "ivs:ListStreams",
          "ivs:ListStreamSessions"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:DescribeAlarms",
          "cloudwatch:GetMetricData",
          "s3:CreateBucket",
          "s3:GetBucketLocation",
          "s3:ListAllMyBuckets",
          "servicequotas:ListAWSDefaultServiceQuotas",
          "servicequotas:ListRequestedServiceQuotaChangeHistoryByQuota",
          "servicequotas:ListServiceQuotas",
          "servicequotas:ListServices",
          "servicequotas:ListTagsForResource"
        ],
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "iam:AttachRolePolicy",
          "iam:CreateServiceLinkedRole",
          "iam:PutRolePolicy"
        ]
        Resource = "arn:aws:iam::*:role/aws-service-role/ivs.amazonaws.com/AWSServiceRoleForIVSRecordToS3*"
      },
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:GetMetricData"
        ]
        Resource = "*"
      }
    ]
  })
}


module "vpc_cni_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "${var.prj_prefix}-vpc_cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}

# ------------------------------------------------------------#
#  aws loadbalancer controller
# ------------------------------------------------------------#

module "lb_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                              = "${var.prj_prefix}-eks-lb-irsa"
  attach_load_balancer_controller_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
}

resource "kubernetes_service_account" "lb_sa" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = module.lb_irsa.iam_role_arn
      "eks.amazonaws.com/sts-regional-endpoints" = "true"
    }
  }
}

# ------------------------------------------------------------#
#  EBS CSI Driver
# ------------------------------------------------------------#

module "ebs_csi_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "${var.prj_prefix}-eks-ebs-irsa"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
}

resource "kubernetes_service_account" "ebs_csi_controller_sa" {
  metadata {
    name      = "ebs-csi-controller-sa"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "ebs-csi-controller-sa"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn" = module.ebs_csi_irsa.iam_role_arn
    }
  }
}

# ------------------------------------------------------------#
#  cluster autoscaler
# ------------------------------------------------------------#

module "cluster_autoscaler_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name                        = "${var.prj_prefix}-cluster-autoscaler-irsa"
  attach_cluster_autoscaler_policy = true
  cluster_autoscaler_cluster_ids   = [module.eks.cluster_name]

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:cluster-autoscaler"]
    }
  }
}

resource "kubernetes_service_account" "cluster_autoscaler_sa" {
  metadata {
    name      = "cluster-autoscaler"
    namespace = "kube-system"
    labels = {
      "app.kubernetes.io/name"      = "cluster-autoscaler"
      "app.kubernetes.io/component" = "controller"
    }
    annotations = {
      "eks.amazonaws.com/role-arn"               = module.cluster_autoscaler_irsa.iam_role_arn
    }
  }
}

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
  subnet_ids               = module.vpc.private_subnets
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

    # `既存にあったのでとりあえず加えておく
    elbv2_8080 = {
      description = "elbv2.k8s.aws/targetGroupBinding=shared"
      protocol    = "tcp"
      from_port   = 8080
      to_port     = 8080
      type        = "ingress"
      cidr_blocks = module.vpc.public_subnets_cidr_blocks
    }
    elbv2_8443 = {
      description = "elbv2.k8s.aws/targetGroupBinding=shared"
      protocol    = "tcp"
      from_port   = 8443
      to_port     = 8443
      type        = "ingress"
      cidr_blocks = module.vpc.public_subnets_cidr_blocks
    }
  }

  # EKS Managed Node Group(s)
  eks_managed_node_groups = {
    bottolerocket = {
      name = "dk-us-mng-spot"

      subnet_ids = module.vpc.private_subnets

      min_size     = 2
      max_size     = 5
      desired_size = 2

      ami_type       = "BOTTLEROCKET_x86_64"
      platform       = "bottlerocket"
      instance_types = ["m5.xlarge", "m4.xlarge", "m3.xlarge", "t3.xlarge", "t2.xlarge"]
      capacity_type  = "SPOT"
      # create_security_group = false
      # attach_cluster_primary_security_group = true
      # vpc_security_group_ids                = [aws_security_group.additional.id]

      # We are using the IRSA created below for permissions
      # However, we have to deploy with the policy attached FIRST (when creating a fresh cluster)
      # and then turn this off after the cluster/node group is created. Without this initial policy,
      # the VPC CNI fails to assign IPs and nodes cannot join the cluster
      # See https://github.com/aws/containers-roadmap/issues/1666 for more context
      iam_role_attach_cni_policy = true

    }
  }

  tags = { "karpenter.sh/discovery" = "${var.cluster_name}" }
}


module "vpc_cni_irsa" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name             = "vpc_cni"
  attach_vpc_cni_policy = true
  vpc_cni_enable_ipv4   = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:aws-node"]
    }
  }
}
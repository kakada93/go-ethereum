data "aws_caller_identity" "current" {}

locals {
  aws_auth_cluster_admins  = [for id in var.eks_cluster_admins:
    {
      userarn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:user/${id}"
      username = "k8s-admin-{{SessionName}}"
      groups   = ["system:masters"]
    }
  ]
  #eks_cluster_admin_roles
  aws_auth_cluster_admin_roles = [for id in var.eks_cluster_admin_roles:
    {
      rolearn  = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:role/${id}"
      username = "k8s-admin-{{SessionName}}"
      groups   = ["system:masters"]
    }
  ]
}


data "aws_iam_policy_document" "service_account_kms" {
  statement {
    sid       = "AllowFullkmsAccess"
    actions   = ["kms:*"] # "iam:*","elasticache:*"
    resources = ["*"]
  }
}

#data "aws_iam_policy_document" "service_account_rdsiam" {
#  statement {
#    sid       = "AllowRDSiamAccess"
#    actions   = ["rds-db:connect","rds-db:*"]
#    resources = ["arn:aws:rds-db:${var.region}:${data.aws_caller_identity.current.account_id}:dbuser:*/*"]
#  }
#}

#module "iam_policy_eks_sa_kms" {
#  source = "terraform-aws-modules/iam/aws//modules/iam-policy"
#
#  name        = "pop_eks_sa_kms_ng"
#  path        = "/"
#  description = "Policy for ServiceAccounts allowing KMS access"
#
#  policy = data.aws_iam_policy_document.service_account_kms.json
#
#  tags = {
#    PolicyDescription = "Policy for ServiceAccounts allowing KMS access"
#  }
#}

#module "iam_policy_eks_sa_rdsiam" {
#  source = "terraform-aws-modules/iam/aws//modules/iam-policy"
#
#  name        = "pop_eks_sa_rdsiam_ng"
#  path        = "/"
#  description = "Policy for ServiceAccounts allowing RDS_IAM access"
#
#  policy = data.aws_iam_policy_document.service_account_rdsiam.json
#
#  tags = {
#    PolicyDescription = "Policy for ServiceAccounts allowing RDS_IAM access"
#  }
#}

module "aws_ebs_csi_irsa_role" {
  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"

  role_name         = "${var.eks_cluster_name}-ebs-csi-role"
  role_description  = "Role for AWS EBS CSI-driver for EKS."

  attach_ebs_csi_policy = true
  attach_load_balancer_controller_policy = true
  #policy = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/pop_eks_sa_kms"

  role_policy_arns = {
    #policy_kms_custom = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/pop_eks_sa_kms_ng"
  }

 #ebs_csi_kms_cmk_ids   = var.eks_ebs_csi_kms_cmk_ids


 assume_role_condition_test     = "StringLike"
 oidc_providers = {
   main = {
     provider_arn               = module.tf-aws-eks.oidc_provider_arn
     namespace_service_accounts = [
       "kube-system:ebs-csi-controller-sa",
       "kube-system:lbc-aws-load-balancer-controller",
       "kube-system:ingress-nginx",
       "*:*",
      ]
    }
  }
}


module "tf-aws-eks" {
  source                         = "./modules/tf-module-eks"
  # In case pipeline with Token is used -> Use the below example
  #source                        = "git::https://gitlab.itgix.com/educatedguessteam/tf-modules/tf-module-eks.git?ref=main"

  cluster_name                    = var.eks_cluster_name
  cluster_version                 = var.eks_cluster_version
  vpc_id                          = module.tf-aws-vpc.vpc.id
  subnet_ids                      = module.tf-aws-vpc.private_subnet[*].id 

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true
  enable_irsa                     = true

  create_cloudwatch_log_group     = false

  ############################
  ### EKS Cluster Add-ons ###
  ############################

  cluster_addons = {
    coredns = {
      most_recent   = var.eks_addon_coredns_version == null ? true : null,
      addon_version = var.eks_addon_coredns_version
    }
    kube-proxy = {
      most_recent   = var.eks_addon_kubeproxy_version == null ? true : null,
      addon_version = var.eks_addon_kubeproxy_version
    }
    vpc-cni = {
      most_recent   = var.eks_addon_vpccni_version == null ? true : null,
      addon_version = var.eks_addon_vpccni_version
    }
    aws-ebs-csi-driver = {
     most_recent               = var.eks_addon_ebscsi_version == null ? true : null,
     addon_version             = var.eks_addon_ebscsi_version,
     service_account_role_arn  = module.aws_ebs_csi_irsa_role.iam_role_arn
    }
  }

  ################################
  ### Node Group configuration ###
  ################################
  eks_managed_node_group_defaults = {
    use_name_prefix = true
    # If desired to change the appended string to the Worker Node Name
    #prefix_separator = ""
    #name_preffix = "test"
    #enable_bootstrap_user_data = true
  }
  eks_managed_node_groups = {
    "${var.eks_cluster_name}-workers" = {
      use_custom_launch_template = true
      create       = var.eks_enable_worker_node_group
      # Not supported in custom Launch configuration. See below block_device_mappings block
      #disk_size    = "80"
      min_size     = var.eks_worker_min_nodes_count
      max_size     = var.eks_worker_max_nodes_count
      desired_size = var.eks_worker_desired_nodes_count

      cluster_version = var.eks_worker_node_group_version != "" ? var.eks_worker_node_group_version : var.eks_cluster_version
      instance_types  = var.eks_worker_instance_type
      capacity_type   = "ON_DEMAND"
      platform        = var.eks_platform
      ami_type        = var.eks_platform == "bottlerocket" ? "BOTTLEROCKET_x86_64" : "AL2_x86_64"

      # Create and set name to empty string for custom Launch Config
      create_launch_template = true
      launch_template_name = ""
      iam_role_attach_cni_policy = true
      iam_role_additional_policies = {
        ecrpower = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
        kmsmorepower = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/pop_eks_sa_kms_ng"
      }
      key_name = var.eks_worker_ssh_key
      # remote_access = {
      #   ec2_ssh_key               = var.eks_worker_ssh_key
      #   #source_security_group_ids = [aws_security_group.remote_access.id]
      # }
      tags = {}

      labels = {
        "nodegroup-role"  = "cpu-worker"
        "nodegroup-class" = "cpu-compute"
        "name"            = "cpu-node"
      }
      # If using custom Launch Configuration this will create a new disk size and mount it. Does not work with disk_size in node settings above.
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = var.eks_worker_disk_size
            volume_type           = var.eks_worker_disk_type
            encrypted             = false
            delete_on_termination = true
          }
        }
      }
    }
    "${var.eks_cluster_name}-infra" = {
      use_custom_launch_template = true
      create       = var.eks_enable_infra_node_group
      # Not supported in custom Launch configuration. See below block_device_mappings block
      #disk_size    = "80"
      min_size     = var.eks_infra_min_nodes_count
      max_size     = var.eks_infra_max_nodes_count
      desired_size = var.eks_infra_desired_nodes_count

      cluster_version = var.eks_infra_node_group_version != "" ? var.eks_infra_node_group_version : var.eks_cluster_version
      instance_types  = var.eks_infra_instance_type
      capacity_type   = "ON_DEMAND"
      platform        = var.eks_platform
      ami_type        = var.eks_platform == "bottlerocket" ? "BOTTLEROCKET_x86_64" : "AL2_x86_64"

      # Create and set name to empty string for custom Launch Config
      create_launch_template = true
      launch_template_name = ""
      iam_role_attach_cni_policy = true
      iam_role_additional_policies = {
        efskms = "arn:aws:iam::aws:policy/AWSKeyManagementServicePowerUser"
        ecrpower = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
      }
      key_name = var.eks_worker_ssh_key
      tags = {}

      labels = {
        "nodegroup-role"  = "infra"
        "nodegroup-class" = "infra"
        "name"            = "infra"
      }
      taints = {
        dedicated = {
          key    = "dedicated"
          value  = "infraGroup"
          effect = "NO_SCHEDULE"
        }
      }
      # If using custom Launch Configuration this will create a new disk size and mount it. Does not work with disk_size in node settings above.
      block_device_mappings = {
        xvda = {
          device_name = "/dev/xvda"
          ebs = {
            volume_size           = var.eks_infra_disk_size
            volume_type           = var.eks_infra_disk_type
            encrypted             = false
            delete_on_termination = true
          }
        }
      }
    }
  }

  ####################################
  ### Security Group configuration ###
  ####################################

  node_security_group_additional_rules = {
    ingress_icmp = {
      description = "Allow inbound ICMP from Intranet and private networks."
      protocol    = "icmp"
      from_port   = -1
      to_port     = -1
      type        = "ingress"
      cidr_blocks = concat(var.vpc_private_subnet_cidrs, var.vpc_public_subnet_cidrs)
    }
    ssh = {
      description = "Allow inbound SSH from Intranet and private networks."
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      type        = "ingress"
      cidr_blocks = concat(var.vpc_private_subnet_cidrs, var.vpc_public_subnet_cidrs)
    }
    ingress_webhook_to_node = {
      description      = "Cluster to ingress-nginx webhook"
      protocol         = "-1"
      from_port        = "8443"
      to_port          = "8443"
      type             = "ingress"
      source_cluster_security_group = true
    }
    #lb_controller_webhook = {
    #  description      = "Cluster to lb-controller webhook"
    #  protocol         = "-1"
    #  from_port        = 9443
    #  to_port          = 9443
    #  type             = "ingress"
    #  source_cluster_security_group = true
    #}
  }

  ##########################
  ### aws-auth Configmap ###
  ##########################

  manage_aws_auth_configmap = true
  # Not needed if Using EKS Managed Nodes
  create_aws_auth_configmap = false
  aws_auth_roles = local.aws_auth_cluster_admin_roles
  aws_auth_users = local.aws_auth_cluster_admins

  ############
  ### Tags ###
  ############

  cluster_tags = {
    "k8s.io/cluster-autoscaler/enabled"                 = "true",  # Value does not matter, only key
    "k8s.io/cluster-autoscaler/${var.eks_cluster_name}" = "owned", # Value does not matter, only key
  }

  tags = merge(var.global_tags, var.eks_cluster_tags)
}

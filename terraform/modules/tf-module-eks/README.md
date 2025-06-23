```

#module "aws_ebs_csi_irsa_role" {
#  source = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#
#  role_name         = "eks-ebs-csi-role"
#  role_description  = "Role for AWS EBS CSI-driver for EKS."
#
#  attach_ebs_csi_policy = true
#  #ebs_csi_kms_cmk_ids   = var.eks_ebs_csi_kms_cmk_ids
#
#  oidc_providers = {
#    main = {
#      provider_arn               = module.eks-new[0].oidc_provider_arn
#      namespace_service_accounts = [
#        "kube-system:ebs-csi-controller-sa" # Don't change this name unless requested by AWS. See documentation: https://docs.aws.amazon.com/eks/latest/userguide/csi-iam-role.html
#      ]
#    }
#  }
#}

#module "vpc_cni_irsa" {
#  source      = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
#
#  role_name   = "vpc-cni"
#
#  attach_vpc_cni_policy = true
#  vpc_cni_enable_ipv4   = true
#
#  oidc_providers = {
#    main = {
#      provider_arn               = "module.eks-new[0].oidc_provider_arn"
#      namespace_service_accounts = ["kube-system:aws-node"]
#    }
#  }
#  tags = {
#    Name = "vpc-cni-irsa"
#  }
#}

module "eks-new" {
  count = var.enable_eks_module ? 1 : 0

  source  = "./modules/tf-module-eks/"

  cluster_name                    = var.eks_cluster_name
  cluster_version                 = var.eks_cluster_version
  vpc_id                          = "vpc-0d85ff4ef3c7bc4cb"
  subnet_ids                      = ["subnet-02312643fa37ae43d", "subnet-05f9d0978db25042d", "subnet-01f9f41610a6e8ff7"]#["subnet-0fbafafebb9a214a9", "subnet-000a7a4c53f935267", "subnet-0a39ab38f9fe72603"]
  #control_plane_subnet_ids        = ["subnet-0fbafafebb9a214a9", "subnet-000a7a4c53f935267", "subnet-0a39ab38f9fe72603"]
  cluster_endpoint_public_access  = var.eks_enable_public_access
  enable_irsa                     = true

  cluster_endpoint_private_access = true
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
    #aws-ebs-csi-driver = {
    #  most_recent               = var.eks_addon_ebscsi_version == null ? true : null,
    #  addon_version             = var.eks_addon_ebscsi_version,
    #  service_account_role_arn  = module.aws_ebs_csi_irsa_role.iam_role_arn
    #}
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
    worker_nodes_new = {
      use_custom_launch_template = true
      create       = var.eks_enable_worker_node_new
      # Not supported in custom Launch configuration. See below block_device_mappings block
      #disk_size    = "80" 
      min_size     = var.eks_min_nodes_count
      max_size     = var.eks_max_nodes_count
      desired_size = var.eks_nodes_count

      cluster_version = var.eks_worker_node_new_group_version
      instance_types  = var.eks_instance_type
      capacity_type   = "ON_DEMAND"
      platform        = var.eks_platform
      ami_type        = var.eks_platform == "bottlerocket" ? "BOTTLEROCKET_x86_64" : "AL2_x86_64"

      # Create and set name to empty string for custom Launch Config
      create_launch_template = true
      launch_template_name = ""
      #iam_role_attach_cni_policy = true
      #remote_access = {
      #  ec2_ssh_key               = "itgix_transactive_dev"
      #  #source_security_group_ids = [aws_security_group.remote_access.id]
      #}
      tags = {
        #"k8s.io/cluster-autoscaler/${var.eks_cluster_name}" = "owned"
      }
      
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
            volume_size           = "80"
            volume_type           = "gp2"
            encrypted             = false
            delete_on_termination = true
          }
        }
      }
    }
    jenkins_node_new = {
      use_custom_launch_template = false
      create       = var.eks_enable_jenkins_node_new
      disk_size    = "80" #If using default Launch Template this will create a /dev/xvdb disk with the desired size. Does not work with custom LC.
      min_size     = var.eks_min_nodes_count
      max_size     = var.eks_max_nodes_count
      desired_size = var.eks_nodes_count

      cluster_version = var.eks_jenkins_node_new_group_version
      instance_types  = var.eks_instance_type
      capacity_type   = "ON_DEMAND"
      platform        = var.eks_platform
      ami_type        = var.eks_platform == "bottlerocket" ? "BOTTLEROCKET_x86_64" : "AL2_x86_64"
    }
  }

  #########################
  ### KMS configuration ###
  #########################

  #kms_key_administrators = [
  #  "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
  #]

  ####################################
  ### Security Group configuration ###
  ####################################

  node_security_group_additional_rules = {
   # ingress_alb = {
   #   description              = "Allow inbound traffic from ALB. NodePorts exposed ports are in range between 30000 and 32767."
   #   protocol                 = "tcp"
   #   from_port                = 30000
   #   to_port                  = 32767
   #   type                     = "ingress"
   #   source_security_group_id = aws_security_group.alb_eks_sg[0].id
   # },
    ingress_icmp = {
      description = "Allow inbound ICMP from Intranet and private networks."
      protocol    = "icmp"
      from_port   = -1
      to_port     = -1
      type        = "ingress"
      cidr_blocks = [ "172.31.64.0/20", "172.31.80.0/20", "172.31.208.0/20" ]
    }
    ssh = {
      description = "Allow inbound SSH from Intranet and private networks."
      protocol    = "tcp"
      from_port   = 22
      to_port     = 22
      type        = "ingress"
      cidr_blocks = [ "172.31.64.0/20", "172.31.80.0/20", "172.31.208.0/20" ]
    }
  }
  
  ##########################
  ### aws-auth Configmap ###
  ##########################

  manage_aws_auth_configmap = true
  # Not needed if Using EKS Managed Nodes
  create_aws_auth_configmap = false
  aws_auth_roles = [ ]
  aws_auth_users = [
    {
      userarn  = "arn:aws:iam::722377226063:user/borislav.dimitrov@itgix.com"
      username = "k8s-admin-{{SessionName}}"
      groups   = ["system:masters"]
    },
    {
      userarn  = "arn:aws:iam::722377226063:user/alexander.alexiev@itgix.com"
      username = "k8s-admin-{{SessionName}}"
      groups   = ["system:masters"]
    },
  ]

  ############
  ### Tags ###
  ############

  cluster_tags = {
    "k8s.io/cluster-autoscaler/enabled"                 = "false",  # Value does not matter, only key
    "k8s.io/cluster-autoscaler/${var.eks_cluster_name}" = "owned", # Value does not matter, only key
  }

  tags = {
    "testing" = "new" 
  }
}
```

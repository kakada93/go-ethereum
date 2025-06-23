locals {
  ecr_ep_enabled = var.enable_ecr_vpc_endpoints     ? (var.enable_private_network ? true : false) : false
  s3_ep_enabled  = var.enable_s3_vpc_endpoint       ? (var.enable_private_network ? true : false) : false
  sqs_ep_enabled = var.enable_sqs_sns_vpc_endpoints ? (var.enable_private_network ? true : false) : false

  vpc_endpoint_sg_enabled = local.ecr_ep_enabled ? 1 : (local.s3_ep_enabled ? 1 : (local.sqs_ep_enabled ? 1 : 0))
}

# Enables Private VPC access to ECR Docker API - pull/push
resource "aws_vpc_endpoint" "ecr-dkr-endpoint" {
  count               = var.enable_ecr_vpc_endpoints ? (var.enable_private_network ? 1 : 0) : 0
  vpc_id              = aws_vpc.vpc.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.aws_region}.ecr.dkr"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoint[0].id]
  subnet_ids          = "${aws_subnet.private_subnet.*.id}"
  tags = merge(
    var.global_tags,
    { Name = "${var.name_prefix}-endpoint-ecr.dkr" }
  )
}
# Enables Private VPC access to ECR Api - list,describe etc
resource "aws_vpc_endpoint" "ecr-api-endpoint" {
  count               = var.enable_ecr_vpc_endpoints ? (var.enable_private_network ? 1 : 0) : 0
  vpc_id              = aws_vpc.vpc.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.aws_region}.ecr.api"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoint[0].id]
  subnet_ids          = "${aws_subnet.private_subnet.*.id}"
  tags = merge(
    var.global_tags,
    { Name = "${var.name_prefix}-endpoint-ecr.api" }
  )
}

# Enables Private VPC access to S3
resource "aws_vpc_endpoint" "s3" {
  count               = var.enable_s3_vpc_endpoint ? (var.enable_private_network ? 1 : 0) : 0
  vpc_id              = aws_vpc.vpc.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.aws_region}.s3"
  vpc_endpoint_type   = "Interface"
  #ip_address_type     = "dualstack"
  #security_group_ids = var.vpc_ecr_endpoint_security_groups
  security_group_ids  = [aws_security_group.vpc_endpoint[0].id]
  subnet_ids          = flatten([
                                 aws_subnet.private_subnet.*.id
                                ])

  dns_options {
    #dns_record_ip_type                             = "dualstack"
    private_dns_only_for_inbound_resolver_endpoint = false
  }

  tags = merge(
    var.global_tags,
    { Name = "${var.name_prefix}-endpoint-s3" }
  )
}

resource "aws_vpc_endpoint" "sqs" {
  count               = var.enable_sqs_sns_vpc_endpoints ? (var.enable_private_network ? 1 : 0) : 0
  vpc_id              = aws_vpc.vpc.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.aws_region}.sqs"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoint[0].id]
  subnet_ids          = flatten([
                                 aws_subnet.private_subnet.*.id
                                ])

  tags = merge(
    var.global_tags,
    { Name = "${var.name_prefix}-endpoint-sqs" }
  )
}

resource "aws_vpc_endpoint" "sns" {
  count               = var.enable_sqs_sns_vpc_endpoints ? (var.enable_private_network ? 1 : 0) : 0
  vpc_id              = aws_vpc.vpc.id
  private_dns_enabled = true
  service_name        = "com.amazonaws.${var.aws_region}.sns"
  vpc_endpoint_type   = "Interface"
  security_group_ids  = [aws_security_group.vpc_endpoint[0].id]
  subnet_ids          = flatten([
                                 aws_subnet.private_subnet.*.id
                                ])

  tags = merge(
    var.global_tags,
    { Name = "${var.name_prefix}-endpoint-sqs" }
  )
}

resource "aws_security_group" "vpc_endpoint" {
  count       = local.vpc_endpoint_sg_enabled
  name        = "vpc_endpoint_${var.name_prefix}_sg"
  description = "${var.name_prefix} VPC Endpoint security group. Allow Connections from private networks"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(
    var.global_tags,
    { Name = "${var.name_prefix}-vpc-endpoint-sg" }
  )
}

resource "aws_security_group_rule" "allow_outgoing_traffic" {
  count             = local.vpc_endpoint_sg_enabled
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.vpc_endpoint[0].id
}

resource "aws_security_group_rule" "allow_incoming_traffic" {
  count                    = local.vpc_endpoint_sg_enabled
  security_group_id        = aws_security_group.vpc_endpoint[0].id
  type                     = "ingress"
  description              = "Allow incoming connections from the whole VPC"
  from_port                = 0
  to_port                  = 0
  protocol                 = "-1"
  cidr_blocks              = [var.cidr_block]
}

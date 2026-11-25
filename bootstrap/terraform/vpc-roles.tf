resource "aws_iam_policy" "vpc_tofu_apply" {
  name        = "vpc-tofu-apply"
  path        = "/"
  description = "CI apply policy — permissions for terraform apply aws/vpc"

  policy = data.aws_iam_policy_document.vpc_tofu_apply.json
}

data "aws_iam_policy_document" "vpc_tofu_apply" {
  statement {
    actions = [
      "ec2:AllocateAddress",
      "ec2:AssignPrivateNatGatewayAddress",
      "ec2:AssociateAddress",
      "ec2:AssociateNatGatewayAddress",
      "ec2:AssociateRouteTable",
      "ec2:AssociateSubnetCidrBlock",
      "ec2:AttachInternetGateway",
      "ec2:CreateInternetGateway",
      "ec2:CreateNatGateway",
      "ec2:CreateRouteTable",
      "ec2:CreateSubnet",
      "ec2:CreateTags",
      "ec2:CreateVPC",
      "ec2:CreateVpcEndpoint",
      "ec2:DeleteInternetGateway",
      "ec2:DeleteNatGateway",
      "ec2:DeleteRouteTable",
      "ec2:DeleteSubnet",
      "ec2:DeleteTags",
      "ec2:DeleteVPC",
      "ec2:DeleteVpcEndpoints",
      "ec2:DescribeAccountAttributes",
      "ec2:DescribeAddresses",
      "ec2:DescribeAvailabilityZones",
      "ec2:DescribeInternetGateways",
      "ec2:DescribeNatGateways",
      "ec2:DescribeNetworkAcls",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DescribePrefixLists",
      "ec2:DescribeRouteTables",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcAttribute",
      "ec2:DescribeVpcEndpointServices",
      "ec2:DescribeVpcEndpoints",
      "ec2:DescribeVpcs",
      "ec2:DetachInternetGateway",
      "ec2:DisassociateAddress",
      "ec2:DisassociateNatGatewayAddress",
      "ec2:DisassociateRouteTable",
      "ec2:DisassociateSubnetCidrBlock",
      "ec2:ModifySubnetAttribute",
      "ec2:ModifyVpcAttribute",
      "ec2:ModifyVpcEndpoint",
      "ec2:ModifyVpcTenancy",
      "ec2:ReleaseAddress",
      "ec2:ReplaceRouteTableAssociation",
      "ec2:UnassignPrivateNatGatewayAddress"
    ]
    resources = ["*"]
  }
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.state.arn]
  }
  statement {
    actions = [
      "s3:DeleteObject",
      "s3:GetObject",
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.state.arn}/k8s-lab/aws/vpc/*"]
  }
}
resource "aws_iam_role" "vpc_tofu_apply" {
  name               = "vpc-tofu-apply"
  assume_role_policy = data.aws_iam_policy_document.trust.json
}

resource "aws_iam_role_policy_attachment" "vpc_tofu_apply" {
  role       = aws_iam_role.vpc_tofu_apply.name
  policy_arn = aws_iam_policy.vpc_tofu_apply.arn
}

resource "aws_iam_policy" "vpc_tofu_plan" {
  name        = "vpc-tofu-plan"
  path        = "/"
  description = "CI plan policy — permissions for terraform plan aws/vpc"
  policy      = data.aws_iam_policy_document.vpc_tofu_plan.json
}
data "aws_iam_policy_document" "vpc_tofu_plan" {
  statement {
    actions   = ["ec2:Describe*"]
    resources = ["*"]
  }
  statement {
    actions   = ["s3:ListBucket"]
    resources = [aws_s3_bucket.state.arn]
  }
  statement {
    actions = [
      "s3:GetObject",
    ]
    resources = ["${aws_s3_bucket.state.arn}/k8s-lab/aws/vpc/terraform.tfstate"]
  }
  statement {
    actions = [
      "s3:DeleteObject",
      "s3:PutObject"
    ]
    resources = ["${aws_s3_bucket.state.arn}/k8s-lab/aws/vpc/terraform.tfstate.tflock"]
  }
}
resource "aws_iam_role" "vpc_tofu_plan" {
  name               = "vpc-tofu-plan"
  assume_role_policy = data.aws_iam_policy_document.trust_pr.json
}

resource "aws_iam_role_policy_attachment" "vpc_tofu_plan" {
  role       = aws_iam_role.vpc_tofu_plan.name
  policy_arn = aws_iam_policy.vpc_tofu_plan.arn
}
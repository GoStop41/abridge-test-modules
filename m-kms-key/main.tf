# Create the environment-level KMS key with appropriate policies

resource "aws_kms_key" "default" {
  description             = "Environment-level shared key for ${var.environment}"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  tags                    = var.tags
  policy                  = data.aws_iam_policy_document.default.json
}

data "aws_caller_identity" "current" {}

locals {
  account_id           = data.aws_caller_identity.current.account_id
  root_arn             = "arn:aws:iam::${local.account_id}:root"
}

data "aws_iam_policy_document" "default" {
  statement {
    sid    = "Enable IAM User Admin Permissions"
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [local.root_arn]
    }
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey",
      "kms:DescribeKey",
      "kms:Create*",
      "kms:Describe*",
      "kms:Enable*",
      "kms:List*",
      "kms:Put*",
      "kms:Update*",
      "kms:Revoke*",
      "kms:Disable*",
      "kms:Get*",
      "kms:Delete*",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    resources = ["*"]
  }

  dynamic "statement" {
    for_each = length(var.cross_account_roles) > 0 ? { CrossAccountRoles = var.cross_account_roles } : {}
    content {
      sid    = statement.key
      effect = "Allow"
      principals {
        type        = "AWS"
        identifiers = var.cross_account_roles
      }
      actions = [
        "kms:Encrypt",
        "kms:Decrypt",
        "kms:ReEncrypt*",
        "kms:GenerateDataKey*",
        "kms:DescribeKey"
      ]
      resources = ["*"]
    }
  }
}

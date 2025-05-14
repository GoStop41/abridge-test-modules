# Create the environment-level KMS key with appropriate policies
variable "environment" {
  type        = string
  description = "The environment name."
}

variable "tags" {
  type        = map(string)
  description = "Tags to apply."
}

variable "cross_account_roles" {
  type        = list(string)
  description = "List of ARNs of roles in other accounts that are allowed to use this key. For roles in this account, use policies attached to the role rather than the CMK."
  default     = []
}

resource "aws_kms_key" "default" {
  description             = "Environment-level shared key for ${var.environment}"
  enable_key_rotation     = true
  deletion_window_in_days = 7
  tags                    = var.tags
  policy                  = data.aws_iam_policy_document.default.json
}

output "arn" {
  value = aws_kms_key.default.arn
}

output "id" {
  value = aws_kms_key.default.id
}

data "aws_caller_identity" "current" {}

locals {
  account_id           = data.aws_caller_identity.current.account_id
  root_arn             = "arn:aws:iam::${local.account_id}:root"
}

data "aws_iam_policy_document" "default" {
  statement {
    sid    = "Enable IAM User Permissions"
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
      "kms:DescribeKey"
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

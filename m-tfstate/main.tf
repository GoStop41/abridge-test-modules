data "aws_caller_identity" "main" {}

resource "aws_s3_bucket" "state_bucket" {
  bucket = local.state_bucket_name

  policy = data.aws_iam_policy_document.s3_https_only_policy.json

  tags = local.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "state_bucket_sse_config" {
  bucket = aws_s3_bucket.state_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.terraform_key.id
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "state_bucket_versioning" {
  bucket = aws_s3_bucket.state_bucket.id

  versioning_configuration {
    status = "Enabled"
  }
}

data "aws_iam_policy_document" "s3_https_only_policy" {
  statement {
    sid    = "HTTPS_Only"
    effect = "Deny"
    actions = [
      "s3:*",
    ]
    resources = [
      "arn:aws:s3:::${local.state_bucket_name}",
      "arn:aws:s3:::${local.state_bucket_name}/*"
    ]
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
    condition {
      test     = "Bool"
      values   = ["false"]
      variable = "aws:SecureTransport"
    }
  }
  statement {
    sid    = ""
    effect = "Deny"
    actions = [
      "s3:DeleteBucket"
    ]
    resources = [
      "arn:aws:s3:::${local.state_bucket_name}"
    ]
    condition {
      test     = "Null"
      values   = ["true"]
      variable = "aws:MultiFactorAuthAge"
    }
    principals {
      identifiers = ["*"]
      type        = "AWS"
    }
  }
}

resource "aws_dynamodb_table" "state_lock_table" {
  name = local.state_bucket_name

  hash_key       = "LockID"
  read_capacity  = 3
  write_capacity = 3

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = local.tags
}

resource "aws_kms_alias" "terraform_key" {
  name          = "alias/${local.state_bucket_name}"
  target_key_id = aws_kms_key.terraform_key.id
}

resource "aws_kms_key" "terraform_key" {
  description = "Terraform State KMS Key"
  policy      = data.aws_iam_policy_document.terraform_kms_key_policy.json

  enable_key_rotation = true
}

data "aws_iam_policy_document" "terraform_kms_key_policy" {
  statement {
    sid    = "Enable IAM User Permissions"
    effect = "Allow"
    actions = [
      "kms:*"
    ]
    resources = [
      "*"
    ]
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.main.account_id}:root"
      ]
      type = "AWS"
    }
  }
  statement {
    sid    = "Allow access for Key Administrators"
    effect = "Allow"
    actions = [
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
      "kms:TagResource",
      "kms:UntagResource",
      "kms:ScheduleKeyDeletion",
      "kms:CancelKeyDeletion"
    ]
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.main.account_id}:role/${var.terraform_parent_role}"
      ]
      type = "AWS"
    }
    resources = [
      "*"
    ]
  }
  statement {
    sid    = "Allow use of the key"
    effect = "Allow"
    actions = [
      "kms:Encrypt",
      "kms:Decrypt",
      "kms:ReEncrypt*",
      "kms:GenerateDataKey*",
      "kms:DescribeKey"
    ]
    principals {
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.main.account_id}:role/${var.terraform_parent_role}",
        "arn:aws:iam::${data.aws_caller_identity.main.account_id}:root"
      ]
      type = "AWS"
    }
    resources = [
      "*"
    ]
  }
}

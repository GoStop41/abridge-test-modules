data "aws_iam_policy_document" "service_account_policy_doc" {
  dynamic "statement" {
    for_each = var.role_policy
    content {
      sid       = statement.key
      effect    = statement.value.effect
      resources = statement.value.resources
      actions   = statement.value.actions
    }
  }
}

resource "aws_iam_role_policy" "service_account_policy" {
  count  = var.role_policy != {} ? 1 : 0
  name   = "${var.cluster_name}_oidc-${var.service_account_name}"
  policy = data.aws_iam_policy_document.service_account_policy_doc.json
  role   = aws_iam_role.service_role.name
}

resource "kubernetes_service_account" "service_account" {
  automount_service_account_token = true
  metadata {
    name      = var.service_account_name
    namespace = var.namespace
    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.service_role.arn
    }
  }
}

resource "aws_iam_role" "service_role" {
  name               = "${var.cluster_name}_oidc-${var.service_account_name}"
  tags               = var.tags
  assume_role_policy = data.aws_iam_policy_document.trust_policy.json
  description        = "Role for ServiceAccount ${var.service_account_name} in ${var.namespace} namspace of ${var.cluster_name} EKS k8s cluster"
}

data "aws_iam_policy_document" "trust_policy" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [var.oidc_provider_arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${replace(var.oidc_provider_arn, "/arn:aws:iam::[0-9]{12}:oidc-provider\\//", "")}:sub"
      values   = ["system:serviceaccount:${var.namespace}:${var.service_account_name}"]
    }
  }
}

resource "aws_iam_role_policy_attachment" "role-attachment" {
  for_each   = var.attach_role_policies
  role       = aws_iam_role.service_role.name
  policy_arn = each.value["arn"]
}
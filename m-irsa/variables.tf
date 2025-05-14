variable "tags" {
  description = "A map of tags"
  type        = any
  default     = {}
}

variable "cluster_name" {
  description = "EKS cluster name"
}

variable "oidc_provider_arn" {
  description = "EKS oidc_provider_arn"
}

variable "service_account_name" {
  description = "Service account name"
}

variable "namespace" {
  default = "default"
}

variable "role_policy" {
  description = "Statements for role"
  default     = {}
}

variable "attach_role_policies" {
  description = "Attach additional policies to role"
  default     = {}
}
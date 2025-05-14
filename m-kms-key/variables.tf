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

variable "region" {
  description = "This is the region in which tfstate bucket is created"
  type        = string
}

variable "name" {
  description = "The name of the account"
  type        = string
}

variable "terraform_parent_role" {
  description = "The Terraform Parent IAM role"
  type        = string
}

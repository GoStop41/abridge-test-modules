locals {
  state_bucket_name = "${var.name}-terraform-state"
  tags = {
    Terraform = true
  }
}

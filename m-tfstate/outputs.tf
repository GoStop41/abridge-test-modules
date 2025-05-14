output "state_s3_bucket" {
  description = "S3 bucket for Terraform state"
  value       = aws_s3_bucket.state_bucket
}

output "state_dynamodb_table" {
  description = "DynamoDB table for Terraform state lock"
  value       = aws_dynamodb_table.state_lock_table
}

output "state_kms" {
  description = "KMS for Terraform state"
  value       = aws_kms_key.terraform_key
}
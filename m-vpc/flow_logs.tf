resource "aws_flow_log" "existing_bucket" {
  count                = var.enable_flow_logs == true && var.flow_log_bucket_exists == true ? 1 : 0
  log_destination      = data.aws_s3_bucket.flow_logs[count.index].arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
}

resource "aws_flow_log" "new_bucket" {
  count                = var.enable_flow_logs == true && var.flow_log_bucket_exists == false ? 1 : 0
  log_destination      = aws_s3_bucket.flow_logs[count.index].arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
}

resource "aws_s3_bucket" "flow_logs" {
  count         = var.enable_flow_logs == true && var.flow_log_bucket_exists == false ? 1 : 0
  bucket        = var.flow_log_bucket
  force_destroy = true
}

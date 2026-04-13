# -----------------------------------------------------------------------------
# VPC Flow Logs
# -----------------------------------------------------------------------------

resource "aws_cloudwatch_log_group" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name              = "/aws/vpc/flow-logs/${local.name_prefix}"
  retention_in_days = var.flow_log_retention_days
  kms_key_id        = var.flow_log_kms_key_id

  tags = merge(local.merged_tags, {
    Name = "${local.name_prefix}-flow-logs"
  })
}

resource "aws_iam_role" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name_prefix = "${local.name_prefix}-flow-logs-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "vpc-flow-logs.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(local.merged_tags, {
    Name = "${local.name_prefix}-flow-logs-role"
  })
}

resource "aws_iam_role_policy" "flow_logs" {
  count = var.enable_flow_logs ? 1 : 0

  name_prefix = "${local.name_prefix}-flow-logs-"
  role        = aws_iam_role.flow_logs[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Effect = "Allow"
        Resource = [
          aws_cloudwatch_log_group.flow_logs[0].arn,
          "${aws_cloudwatch_log_group.flow_logs[0].arn}:log-stream:*"
        ]
      }
    ]
  })
}

resource "aws_flow_log" "main" {
  count = var.enable_flow_logs ? 1 : 0

  vpc_id               = aws_vpc.main.id
  traffic_type         = "ALL"
  log_destination_type = "cloud-watch-logs"
  log_destination      = aws_cloudwatch_log_group.flow_logs[0].arn
  iam_role_arn         = aws_iam_role.flow_logs[0].arn

  tags = merge(local.merged_tags, {
    Name = "${local.name_prefix}-flow-log"
  })
}

# -----------------------------------------------------------------------------
# Optional S3 Archival for Flow Logs
# -----------------------------------------------------------------------------

resource "aws_s3_bucket" "flow_logs" {
  count = var.enable_flow_logs && var.enable_flow_logs_s3_archival ? 1 : 0

  bucket_prefix = "${local.name_prefix}-flow-logs-"
  force_destroy = false

  tags = merge(local.merged_tags, {
    Name = "${local.name_prefix}-flow-logs-archive"
  })
}

resource "aws_s3_bucket_lifecycle_configuration" "flow_logs" {
  count = var.enable_flow_logs && var.enable_flow_logs_s3_archival ? 1 : 0

  bucket = aws_s3_bucket.flow_logs[0].id

  rule {
    id     = "glacier-transition"
    status = "Enabled"

    filter {}

    transition {
      days          = 90
      storage_class = "GLACIER"
    }

    expiration {
      days = 365
    }
  }
}

resource "aws_s3_bucket_public_access_block" "flow_logs" {
  count = var.enable_flow_logs && var.enable_flow_logs_s3_archival ? 1 : 0

  bucket = aws_s3_bucket.flow_logs[0].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "flow_logs" {
  count = var.enable_flow_logs && var.enable_flow_logs_s3_archival ? 1 : 0

  bucket = aws_s3_bucket.flow_logs[0].id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "aws:kms"
    }
  }
}

resource "aws_flow_log" "s3" {
  count = var.enable_flow_logs && var.enable_flow_logs_s3_archival ? 1 : 0

  vpc_id               = aws_vpc.main.id
  traffic_type         = "ALL"
  log_destination_type = "s3"
  log_destination      = aws_s3_bucket.flow_logs[0].arn

  tags = merge(local.merged_tags, {
    Name = "${local.name_prefix}-flow-log-s3"
  })
}

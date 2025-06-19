
resource "aws_s3_bucket" "bucket" {
  bucket = var.bucket_name
}



resource "aws_s3_bucket_cors_configuration" "cors" {
  count  = var.cors_rules != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  dynamic "cors_rule" {
    for_each = var.cors_rules
    content {
      allowed_headers = cors_rule.value.allowed_headers
      allowed_methods = cors_rule.value.allowed_methods
      allowed_origins = cors_rule.value.allowed_origins
      expose_headers  = cors_rule.value.expose_headers
      max_age_seconds = cors_rule.value.max_age_seconds
    }
  }
}



resource "aws_s3_bucket_website_configuration" "site_config" {
  count  = var.site_config != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  index_document {
    suffix = var.site_config.index_document
  }

  error_document {
    key = var.site_config.index_document
  }
}



resource "aws_s3_bucket_public_access_block" "example" {
  count  = var.acl_config != null ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = var.acl_config.block_public_acls
  block_public_policy     = var.acl_config.block_public_policy
  ignore_public_acls      = var.acl_config.ignore_public_acls
  restrict_public_buckets = var.acl_config.restrict_public_buckets
}



resource "aws_s3_bucket_policy" "bucket_policy" {
  count  = (var.site_config != null || var.dedicated_user_data != null) ? 1 : 0
  bucket = aws_s3_bucket.bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = flatten([
      var.site_config != null ? [
        {
          Effect = "Allow"
          Principal = {
            AWS = "*"
          }
          Action = [
            "s3:GetObject"
          ]
          Resource = [
            "${aws_s3_bucket.bucket.arn}/*"
          ]
        }
      ] : [],

      var.dedicated_user_data != null ? [
        {
          Effect = "Allow"
          Principal = {
            AWS = aws_iam_user.user[0].arn
          }
          Action = [
            "s3:*Object"
          ]
          Resource = [
            aws_s3_bucket.bucket.arn,
            "${aws_s3_bucket.bucket.arn}/*"
          ]
        }
      ] : []
    ])
  })
}

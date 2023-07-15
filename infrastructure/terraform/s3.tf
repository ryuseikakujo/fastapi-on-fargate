resource "aws_s3_bucket" "alb_log" {
  bucket = "${var.app_name}-alb-log"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_ownership_controls" "alb_log" {
  bucket = aws_s3_bucket.alb_log.id

  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

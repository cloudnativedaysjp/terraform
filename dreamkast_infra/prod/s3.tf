# ------------------------------------------------------------#
# S3 Bucket
# ------------------------------------------------------------#
resource "aws_s3_bucket" "bucket" {
  bucket = "${var.prj_prefix}-${var.s3_bucket_name}"

  tags = {
    Name = "${var.prj_prefix}-${var.s3_bucket_name}"
  }
}

resource "aws_s3_bucket_public_access_block" "bucket_block" {
  bucket = aws_s3_bucket.bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# https://github.com/cloudnativedaysjp/dreamkast/issues/1243
resource "aws_s3_bucket_lifecycle_configuration" "bucket_lifecycle" {
  bucket = aws_s3_bucket.bucket.id

  rule {
    id     = "delete_shrine_cache"
    status = "Enabled"

    filter {
      prefix = "cache/avatar/"
    }
    expiration {
      days = 7
    }
  }

}

# ------------------------------------------------------------#
#  VPCS3Endpoint
# ------------------------------------------------------------#
data "aws_region" "current" {}

resource "aws_vpc_endpoint" "s3" {
  vpc_id          = module.vpc.vpc_id
  service_name    = "com.amazonaws.${data.aws_region.current.name}.s3"
  route_table_ids = module.vpc.private_route_table_ids
}

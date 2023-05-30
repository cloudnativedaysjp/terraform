output "distribution_id" {
  value = aws_cloudfront_distribution.static-www.id
}
  
output "bucket_id" {
  value = aws_s3_bucket.bucket.bucket
}
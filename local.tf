##### almaceno el ARN del bucket en una variable local #####
locals {
  s3_bucket_arn = aws_s3_bucket.micubo.arn
}

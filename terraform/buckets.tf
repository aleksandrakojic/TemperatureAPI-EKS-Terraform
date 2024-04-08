# buckets.tf
resource "aws_s3_bucket" "codepipeline_bucket" {
  bucket = "pipeline-bucket-34aHAhdasD"
}

resource "aws_s3_bucket_acl" "pipebucket_acl" {
  bucket = aws_s3_bucket.codepipeline_bucket.id
  acl    = "private"
}

# Please Note that s3 buckets are globally namespaced so you might need to pick a very specific name as most of them might be already taken

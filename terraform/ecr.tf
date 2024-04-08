# ECR.tf
# This is where our images will be stored.
resource "aws_ecr_repository" "prod-temp-api-repository" {
  name                 = "prod-temp-api"
  image_tag_mutability = "MUTABLE"


  image_scanning_configuration {
    scan_on_push = true
  }
}

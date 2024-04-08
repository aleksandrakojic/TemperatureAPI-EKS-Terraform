# Codepipeline.tf
# Our trust relationship
data "aws_iam_policy_document" "pipeline_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
# Our pipeline role
resource "aws_iam_role" "codepipeline_role" {
  name               = "pipeline-role"
  assume_role_policy = data.aws_iam_policy_document.pipeline_assume_role.json
}

# Our policies, allows S3 access for artifacts and codebuild access to start builds.
data "aws_iam_policy_document" "codepipeline_policy" {
  statement {
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion",
      "s3:GetBucketVersioning",
      "s3:PutObjectAcl",
      "s3:PutObject",
    ]

    resources = [
      aws_s3_bucket.codepipeline_bucket.arn,
      "${aws_s3_bucket.codepipeline_bucket.arn}/*"
    ]
  }

  statement {
    effect = "Allow"

    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
    ]

    resources = ["*"]
  }
}
# Binding the policy document to our role.
resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "codepipeline_policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.aws_iam_policy_document.codepipeline_policy.json
}


resource "aws_codepipeline" "codepipeline" {
  name     = "temp-api-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn # our created role above

# Specifying the artifact store
  artifact_store {
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"
  }


  stage {
    name = "Source"
# Telling codepipeline to pull from third party (github) 
    action {
      name             = "Source"
      category         = "Source"
      owner            = "ThirdParty"
      provider         = "GitHub"
      version          = "1"
      output_artifacts = ["source_output"]
# the output of the source(which is the source code) gets added in a directory called source_output in our s3 bucket
      configuration = {
        Owner      = "<repo-owner>"
        Repo       = "temp-api"
        Branch     = "main"
# Dont forget to create a github token and give it repo privileges
        OAuthToken = "<secret-github-token>"
      }
    }
  }

  stage {
    name = "Build"
# Build stage takes in input from source_output dir (source code) & we provide it only with the codebuild id we created from the first step.
    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      input_artifacts  = ["source_output"]
      output_artifacts = ["build_output"]
      version          = "1"

      configuration = {
        ProjectName = aws_codebuild_project.temp-api-codebuild.name
      }
    }
  }
}

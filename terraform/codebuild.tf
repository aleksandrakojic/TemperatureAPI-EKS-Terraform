#codebuild.tf

# the following is our trust relationship for the build role stating that only codebuild can assume the role.
data "aws_iam_policy_document" "build_assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["codebuild.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}
# We create the role and bind the trust relationship with it
resource "aws_iam_role" "build-role" {
  name               = "codebuild-role"
  assume_role_policy = data.aws_iam_policy_document.build_assume_role.json
}

# Now we add a few policies to the role (what will the role owner be able to do?)
# First access to ECR for pulling and pushing images to it
resource "aws_iam_policy" "build-ecr" {
  name = "ECRPOLICY"
  policy = jsonencode({
    "Statement" : [
      {
        "Action" : [
          "ecr:BatchGetImage",
          "ecr:BatchCheckLayerAvailability",
          "ecr:CompleteLayerUpload",
          "ecr:GetAuthorizationToken",
          "ecr:InitiateLayerUpload",
          "ecr:PutImage",
          "ecr:UploadLayerPart",
        ],
        "Resource" : "*",
        "Effect" : "Allow"
      },
    ],
    "Version" : "2012-10-17"
  })
}
# Another policy that enables us to update our kubeconfig when we're in the build stage
resource "aws_iam_policy" "eks-access" {
  name = "EKS-access"
  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "eks:DescribeCluster"
            ],
            "Resource": "*"
        }
    ]
} )
}

# Binding the 2 previous policies
resource "aws_iam_role_policy_attachment" "eks" {
  role = aws_iam_role.build-role.name
  policy_arn = aws_iam_policy.eks-access.arn
}
resource "aws_iam_role_policy_attachment" "attachmentsss" {
  role = aws_iam_role.build-role.name
  policy_arn = aws_iam_policy.build-ecr.arn
}

# One last policy to give access to S3 for artifacts (codepipeline will throw artifacts into s3 and codebuild needs access to pull it from there & also push the build output into s3)

# This is another way to write the policy, not with jsonencode as above. A local data source using terraform as below.

# This allows codebuild to write logs, get any ec2 network information it needs and access s3. All this is recommended per AWS documentation.
data "aws_iam_policy_document" "build-policy" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = ["*"]
  }

  statement {
    effect = "Allow"

    actions = [
      "ec2:CreateNetworkInterface",
      "ec2:DescribeDhcpOptions",
      "ec2:DescribeNetworkInterfaces",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSubnets",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeVpcs",
    ]

    resources = ["*"]
  }

  statement {
    effect    = "Allow"
    actions   = ["ec2:CreateNetworkInterfacePermission"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "ec2:Subnet"

      values = [
        aws_subnet.private-central-1b.arn,
        aws_subnet.private-central-1a.arn,
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "ec2:AuthorizedService"
      values   = ["codebuild.amazonaws.com"]
    }
  }

  statement {
    effect  = "Allow"
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
}

# Attaching the previous policy
resource "aws_iam_role_policy" "s3_access" {
  role   = aws_iam_role.build-role.name
  policy = data.aws_iam_policy_document.build-policy.json
}

resource "aws_codebuild_project" "temp-api-codebuild" {
  name          = "temp-api"
  build_timeout = "5" # Timeout 5 minutes for this build
  service_role  = aws_iam_role.build-role.arn # Our role we specified above

# Specifying where our artifacts should reside
  artifacts {
    type           = "S3"
    location       = aws_s3_bucket.codepipeline_bucket.bucket
    name           = "temp-api-build-artifacts"
    namespace_type = "BUILD_ID"
  }

# Enviroments specifying the codebuild image and some enviromental variables, privileged mode enables us to access higher privilages when in build mode. It's very important to for example start the docker service and it won't work unless specified true.
  environment {
    privileged_mode = true
    compute_type                = "BUILD_GENERAL1_SMALL"
    image                       = "aws/codebuild/standard:1.0"
    type                        = "LINUX_CONTAINER"
    image_pull_credentials_type = "CODEBUILD"
    environment_variable {
      name = "IMAGE_TAG"
      value = "latest"
    }
    environment_variable {
      name = "IMAGE_REPO_NAME"
      value = "prod-temp-api" # My github repository name
    }
    environment_variable {
      name = "AWS_DEFAULT_REGION"
      value = "eu-central-1" # My AZ
    }
    environment_variable {
      name = "AWS_ACCOUNT_ID"
      value = "<your-aws-account-id>" # AWS account id
    }

  }
# Here i specify where to find the source code for building. in our case buildspec.yaml which resides in our repo. You can omit using a buildspec file and just specify the steps here. Refer to terraform documentation for this.
  source {
    type            = "GITHUB"
    location        = "https://github.com/amrelhewy09/temp-api.git"
    git_clone_depth = 1
    buildspec       = "buildspec.yaml"
  }
}
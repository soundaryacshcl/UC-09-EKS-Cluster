# ECR Repository
data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ecr_kms" {
  statement {
    effect  = "Allow"
    actions = ["kms:*"]
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"]
    }
    resources = ["*"]
  }
}

resource "aws_kms_key" "ecr" {
  description         = "ECR image encryption"
  enable_key_rotation = true
  policy              = data.aws_iam_policy_document.ecr_kms.json
}

resource "aws_kms_alias" "ecr" {
  name          = "alias/${var.name}-ecr"
  target_key_id = aws_kms_key.ecr.id
}

resource "aws_ecr_repository" "flask_app" {
  name                 = "flask-app"
  image_tag_mutability = "IMMUTABLE"

  encryption_configuration {
    encryption_type = "KMS"
    kms_key         = aws_kms_key.ecr.arn
  }

  image_scanning_configuration {
    scan_on_push = true
  }

  tags = {
    Name = "flask-app"
  }
}

# ECR Lifecycle Policy for flask_app
resource "aws_ecr_lifecycle_policy" "flask_app" {
  repository = aws_ecr_repository.flask_app.name

  policy = jsonencode({
    rules = [
      {
        rulePriority = 1
        description  = "Keep last 5 tagged images"
        selection = {
          tagStatus     = "tagged"
          tagPrefixList = ["v"]
          countType     = "imageCountMoreThan"
          countNumber   = 5
        }
        action = {
          type = "expire"
        }
      },
      {
        rulePriority = 2
        description  = "Keep last 3 untagged images"
        selection = {
          tagStatus   = "untagged"
          countType   = "imageCountMoreThan"
          countNumber = 3
        }
        action = {
          type = "expire"
        }
      }
    ]
  })
}

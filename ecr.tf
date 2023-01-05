resource "aws_ecr_repository" "aws-ecr" {
  name = "${var.env}-${var.project_name}-${var.service_name}"
  tags = {
    Name        = "${var.env}-${var.project_name}-${var.service_name}"
    Environment = "${var.env}"
    Management  = "terraform"
  }
}

resource "aws_ecr_lifecycle_policy" "aws-ecr-policy" {
  repository = aws_ecr_repository.aws-ecr.name

  policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 30 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 30
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

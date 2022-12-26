resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "${var.project}-ecs-task-role-${var.env}"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}
resource "aws_iam_role_policy_attachment" "amazon_ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "authenticated_cognito_role" {
  name = "${var.project}-cognito-authenticated"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "cognito-identity.amazonaws.com"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "cognito-identity.amazonaws.com:aud": var.aws_cognito_identity_pool_id
          },
          "ForAnyValue:StringLike": {
            "cognito-identity.amazonaws.com:amr": "authenticated"
          }
        }
      }
    ]
  })
}
resource "aws_iam_role_policy" "authenticated_cognito_policy" {
  name = "authenticated_policy"
  role = aws_iam_role.authenticated_cognito_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "dynamodb:BatchGetItem",
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan",
          "dynamodb:PutItem"
        ],
        "Resource": var.dynamo_db_arn
      }
    ]
  })
}

resource "aws_iam_role" "unauthenticated_cognito_role" {
  name = "${var.project}-cognito-unauthenticated"

  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Federated": "cognito-identity.amazonaws.com"
        },
        "Action": "sts:AssumeRoleWithWebIdentity",
        "Condition": {
          "StringEquals": {
            "cognito-identity.amazonaws.com:aud": var.aws_cognito_identity_pool_id
          },
          "ForAnyValue:StringLike": {
            "cognito-identity.amazonaws.com:amr": "unauthenticated"
          }
        }
      }
    ]
  })
}
resource "aws_iam_role_policy" "unauthenticated_cognito_policy" {
  name = "authenticated_policy"
  role = aws_iam_role.unauthenticated_cognito_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Deny",
        "Action": [
          "*"
        ],
        "Resource": "*"
      }
    ]
  })
}

resource "aws_cognito_identity_pool_roles_attachment" "main" {
  identity_pool_id = var.aws_cognito_identity_pool_id

  roles = {
    "authenticated"   = aws_iam_role.authenticated_cognito_role.arn
    "unauthenticated" = aws_iam_role.unauthenticated_cognito_role.arn
  }
}

resource "aws_cognito_user_pool" "main" {
  name = "${var.app}-auth"

  mfa_configuration = "OFF"
  account_recovery_setting {
    recovery_mechanism {
      name     = "verified_phone_number"
      priority = 1
    }
  }
  admin_create_user_config {
    allow_admin_create_user_only = true
    invite_message_template {
      email_message = "{username}さん、あなたの初期パスワードは {####} です。初回ログインの後パスワード変更が必要です。"
      email_subject = "${var.app}(開発環境)への招待"
      sms_message   = "{username}さん、あなたの初期パスワードは {####} です。初回ログインの後パスワード変更が必要です。"
    }
  }
  
  password_policy {
    minimum_length                   = 6
    require_lowercase                = false 
    require_numbers                  = false 
    require_symbols                  = false 
    require_uppercase                = false 
    temporary_password_validity_days = 0
  }

  alias_attributes = ["email"]
}

resource "aws_cognito_user_pool_domain" "main" {
  domain       = "${var.app}-domain"
  user_pool_id = aws_cognito_user_pool.main.id
}

resource "aws_cognito_user_pool_client" "main" {
  name            = "${var.app}-client"
  user_pool_id    = aws_cognito_user_pool.main.id
  generate_secret = false
  callback_urls = [
    "http://localhost:8080/"
  ]
  allowed_oauth_flows = ["code"]
  explicit_auth_flows = [
    "ALLOW_REFRESH_TOKEN_AUTH",
    "ALLOW_USER_SRP_AUTH",
    "ALLOW_ADMIN_USER_PASSWORD_AUTH"
  ]
  supported_identity_providers = [
    "COGNITO",
  ]
  allowed_oauth_scopes                 = ["openid"]
  allowed_oauth_flows_user_pool_client = true
}

resource "null_resource" "cognito_user" {
  triggers = {
    user_pool_id = aws_cognito_user_pool.main.id
  }

  provisioner "local-exec" {
    command = "aws cognito-idp admin-create-user --user-pool-id ${aws_cognito_user_pool.main.id} --username admin --user-attributes Name=email,Value=${var.admin_user_email} Name=email_verified,Value=True --region ${var.region}"
  }
}
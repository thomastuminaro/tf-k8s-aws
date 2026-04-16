##########################################################################################################################################################
# Creating TLS key
##########################################################################################################################################################

resource "tls_private_key" "workstation" {
  algorithm = "ED25519"
}

##########################################################################################################################################################
# Creating secrets
##########################################################################################################################################################

resource "aws_secretsmanager_secret" "pubkey" {
  name = var.pubkeysecret

  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret" "privatekey" {
  name = var.privatekeysecret

  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "pubkey" {
  secret_id = aws_secretsmanager_secret.pubkey.id
  secret_string = tls_private_key.workstation.public_key_openssh
}

resource "aws_secretsmanager_secret_version" "privatekey" {
  secret_id = aws_secretsmanager_secret.privatekey.id
  secret_string = tls_private_key.workstation.private_key_openssh
}

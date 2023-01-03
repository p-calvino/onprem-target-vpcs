# Terraform outputs
output "webserver_public_ip" {
  value = aws_instance.webserver.public_ip
}

output "database_private_ip" {
  value = aws_instance.database.private_ip
}

output "private_key" {
  value     = tls_private_key.rehost_migration.private_key_pem
  sensitive = true
}

output "access_key" {
  value     = aws_iam_access_key.user_access_key.id
  sensitive = true
}

output "secret_access_key" {
  value     = aws_iam_access_key.user_access_key.secret
  sensitive = true
}
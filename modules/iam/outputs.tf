output "vault_instance_profile" {
  description = "AWS iam instance profile for iam vault_role"
  value = aws_iam_instance_profile.vault_profile.name
}

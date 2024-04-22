resource "tls_private_key" "ca" {
  algorithm = "RSA"
  rsa_bits = 4096
}

resource "tls_self_signed_cert" "ca" {
  private_key_pem = tls_private_key.ca.private_key_pem

  subject {
    common_name = "vault_ca_root"
  }
  
  is_ca_certificate = true
  validity_period_hours = 322

  allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "cert_signing"
  ]
}

resource "tls_private_key" "vault_tls_key" {
  count = var.vault_ec2_count
  
  algorithm = "RSA"
  rsa_bits = 2048
}

resource "tls_cert_request" "vault_req" {
  count = var.vault_ec2_count
  private_key_pem = tls_private_key.vault_tls_key[count.index].private_key_pem

  subject {
    common_name = "vault-cert-node-${count.index}"
  }
  
  ip_addresses = [var.vault_private_ip[count.index]]
}

resource "tls_locally_signed_cert" "vault_cert" {
 count = var.vault_ec2_count

 cert_request_pem = tls_cert_request.vault_req[count.index].cert_request_pem
 ca_private_key_pem = tls_private_key.ca.private_key_pem
 ca_cert_pem = tls_self_signed_cert.ca.cert_pem

 validity_period_hours = 322
 is_ca_certificate = false

 allowed_uses = [
    "key_encipherment",
    "digital_signature",
    "server_auth"
 ]
}
##### print tls files for ansible #####
resource "local_file" "ca_cert" {
  content = tls_self_signed_cert.ca.cert_pem
  filename = "./AnsibleCode/ca_root_cert.pem"
}

resource "local_file" "vault-tls-cert" {
  count = var.vault_ec2_count
  content = tls_locally_signed_cert.vault_cert[count.index].cert_pem
  filename = "./AnsibleCode/vault-tls-cert-${count.index + 1}.pem"
}

resource "local_file" "vault_tls_key" {
  count = var.vault_ec2_count
  content = tls_private_key.vault_tls_key[count.index].private_key_pem
  filename = "./AnsibleCode/vault-tls-key-${count.index + 1}.pem"
}
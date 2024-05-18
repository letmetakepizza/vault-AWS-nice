storage "raft" {
  path    = "/opt/vault/data"
  node_id = "vault-node-${node_index + 1}"

  retry_join {
    auto_join = "provider=aws region=${region} tag_key=Role tag_value=vault_cluster"
  }
}

seal "awskms" {
  region = "us-west-2"
  kms_key_id = "arn:aws:kms:region:your-account-id:key/your-key"
}
listener "tcp" {
  address = "0.0.0.0:8200"
  cluster_address = "0.0.0.0:8201"
  tls_disable = 0
  tls_cert_file = "/opt/vault/tls/tls.cert"
  tls_key_file = "/opt/vault/tls/tls.key"
  tls_ca_file = "/opt/vault/tls/ca_cert.pem"
}

api_addr = "https://${instance_public_ip}:8200"
cluster_addr = "https://${instance_private_ip}:8201"
cluster_name = "vault-nice-cluster"
ui = true
log_level = "trace"
disable_mlock = true

# hashicorp_vault_setup

**Quick Summary:** Configure `vault_config_file`, `tls_cert_file`, and `tls_key_file` parameters in your inventory for successful deployment.

## Description

This Ansible role installs HashiCorp Vault using a binary file. It is designed to work seamlessly with Terraform-generated inventory which assigns each host a unique set of configuration files for robust TLS management and Vault configuration.

## Requirements

Before deploying this Ansible role, ensure that `vault_config_file`, `tls_cert_file`, and `tls_key_file` are defined in your inventory. These settings are critical as they integrate closely with Terraform to manage your Vault instances effectively.

### Integration with Terraform

This role is optimized to work with a Terraform script that dynamically generates an inventory. Here's how Terraform configures it:

```yaml
resource "local_file" "ansible_inventory_yaml" {
  content = yamlencode({
    all = {
      children = {
        vault = {
          vars = {
            ansible_ssh_common_args = "-o ProxyCommand='ssh -o StrictHostKeyChecking=no -W %h:%p -q -i ~/.ssh/${var.ssh_key_name} ubuntu@${var.bastion_public_ip[0]}'"
          },
          hosts = {
            for index, ip in var.vault_instance_private_ip : "vault${index + 1}" => { 
              ansible_host      = ip
              vault_config_file = "vault-config-${index + 1}.hcl"  # Required for Ansible role
              tls_cert_file     = "vault-tls-cert-${index + 1}.pem"  # Required for Ansible role
              tls_key_file      = "vault-tls-key-${index + 1}.pem"  # Required for Ansible role
            }
          }
        }
      }
    }
  })
  filename = "./AnsibleCode/hosts.yml"
}
```
# Example Playbook:
```yaml
- hosts: vault
  become: true
  roles:
    - hashicorp_vault_setup

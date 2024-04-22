resource "local_file" "vault_config" {     # vault.hcl (config file for vault)
  count = var.vault_ec2_count              # Global var
  content = templatefile("${path.module}/templates/vault.hcl.tpl", {
    node_index = count.index
    instance_public_ip = var.vault_instance_public_ip[count.index]
    instance_private_ip = var.vault_instance_private_ip[count.index]
    region = var.region
  })
  filename = "./AnsibleCode/vault-config-${count.index + 1}.hcl"   # Relative to root level (main1.tf)
}

resource "local_file" "ansible_inventory_yaml" {      # Simple Dynamic Inventory for Ansible
  content = yamlencode({
    all = {
      children = {
        vault = {
          vars = {
            ansible_ssh_common_args = "-o ProxyCommand='ssh -o StrictHostKeyChecking=no -W %h:%p -q -i ~/.ssh/${var.ssh_key_name} ubuntu@${var.bastion_public_ip[0]}'"
          }
          hosts = {
            for index, ip in var.vault_instance_private_ip : "vault${index + 1}" => { 
              ansible_host                 = ip
              ansible_user                 = "ubuntu"
              ansible_ssh_private_key_file = pathexpand("~/.ssh/${var.ssh_key_name}")           # pathexpand replaces ~ with $HOME   
              vault_config_file            = "vault-config-${index + 1}.hcl"                    # crucial for Ansible
              tls_cert_file                = "vault-tls-cert-${index + 1}.pem"                  # crucial for Ansible
              tls_key_file                 = "vault-tls-key-${index + 1}.pem"                   # crucial for Ansible
            }
          }
        }
      }
    }
  })
  filename = "./AnsibleCode/hosts.yml"
}

resource "local_file" "ansible_cfg" {
  count    = 1
  content  = file("${path.module}/templates/ansible.cfg.tpl")
  filename = "./AnsibleCode/ansible.cfg"
}

resource "local_file" "vault_systemd_file" {
  count    = 1
  content  = file("${path.module}/templates/vault.service.tpl")
  filename = "./AnsibleCode/vault.service"
}
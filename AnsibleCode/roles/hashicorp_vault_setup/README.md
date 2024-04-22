hashicorp_vault_setup
=========
**Quick Summary:** Just set `vault_config_file` param in your inventory.
**Quick Summary:** Just set `tls_cert_file` param in your inventory.
**Quick Summary:** Just set `tls_key_file` param in your inventory.


Role will install HashiCorp Vault by binary file. 

Requirements.
------------

!Before deploying this Ansible role, ensure the `vault_config_file` `tls_cert_file` `tls_key_file` variables is defined in your inventory, crucial for Terraform integration. The Terraform script dynamically generates an inventory, assigning each host a unique Vault configuration file and manage tls configuration:

!BECAUSE:
TerraformCode/modules/ansible_templates_generator/main.yml/ (string 12+):

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
              ansible_host      = ip
              ...etc...
              vault_config_file = "vault-config-${index + 1}.hcl"           # required for Ansible role
              tls_cert_file     = "vault-tls-cert-${index + 1}.pem"         # required for Ansible role
              tls_key_file      = "vault-tls-key-${index + 1}.pem"          # required for Ansible role
            }
          }
        }
      }
    }
  })
  filename = "./AnsibleCode/hosts.yml"
}


Example Playbook
----------------

    - hosts: vault
      become: true
      roles:
         - hashicorp_vault_install
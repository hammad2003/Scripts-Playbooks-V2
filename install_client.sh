#!/bin/bash

mensaje_smai() {
  figlet "SMAI    CLIENT"
}
mensaje_smai

mensaje_password() {
  figlet "password"
}

# Ejecución de la configuración del cliente mediante Ansible
mensaje_password
sudo ansible-playbook configuration_client.yml -k -b -K
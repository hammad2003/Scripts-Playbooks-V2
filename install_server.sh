#!/bin/bash

mensaje_smai() {
  figlet "SMAI    SERVER"
}
mensaje_smai

mensaje_password() {
  figlet "password"
}

# Ejecución de la configuración del servidor mediante Ansible
mensaje_password
sudo ansible-playbook configuration_server.yml -k -b -K
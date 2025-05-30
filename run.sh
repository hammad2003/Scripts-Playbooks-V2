#!/bin/bash

sudo apt install -y openssh-server ansible sshpass whiptail figlet

mensaje_smai() {
  figlet "SMAI"
}

mensaje_exit() {
  figlet "Exiting..."
}

mensaje_smai

# Generación de clave SSH para acceso seguro
ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -q <<< y

# Copia de la clave pública al servidor remoto
mensaje_password
ssh-copy-id -f -i ~/.ssh/id_rsa.pub usuario@$(hostname -I | cut -d ' ' -f1)

# Preparación del entorno de Ansible
if [ ! -d /etc/ansible ]; then
  sudo mkdir -p /etc/ansible
fi

if [ ! -f /etc/ansible/hosts ]; then
  sudo touch /etc/ansible/hosts
fi

# Función para agregar servidor al archivo de hosts de Ansible si no existe
add_to_ansible_hosts() {
    local server_type=$1
    local ip_address=$2
    if ! grep -q "$ip_address" /etc/ansible/hosts; then
        echo "[$server_type]" | sudo tee -a /etc/ansible/hosts
        echo "$ip_address" | sudo tee -a /etc/ansible/hosts
    fi
}

# Función para crear archivo ansible.cfg si no existe y añadir configuración
configurar_ansible() {
    local config_file="/etc/ansible/ansible.cfg"
    if [ ! -f "$config_file" ]; then
        sudo touch "$config_file"
        echo "[defaults]" | sudo tee -a "$config_file"
        echo "host_key_checking = False" | sudo tee -a "$config_file"
    fi
}

# Crear archivo ansible.cfg si no existe y añadir configuración
configurar_ansible


while true; do
    CHOICE=$(whiptail --title "Script Selection Menu" --menu "Choose a script to run:" 15 60 4 \
        "1" "Instalar TLauncher (Cliente)" \
        "2" "Instalar SMAI (Servidor)" \
        "3" "Salir" 3>&1 1>&2 2>&3)

    # Check if CHOICE is empty (user pressed Cancel or closed the dialog)
    if [ -z "$CHOICE" ]; then
        mensaje_exit
        exit 0
    fi

    case $CHOICE in
        1)
            echo "Instalando TLauncher (Cliente)..."
            # Ejecutar el script de instalación del cliente si existe
            if [ -f "install_client.sh" ]; then
                chmod +x install_client.sh
                ./install_client.sh
            else
                whiptail --title "Error" --msgbox "install_client.sh not found!" 8 45
            fi
            # Agregar al archivo de hosts solo si no existe
            add_to_ansible_hosts "clientes" "$(hostname -I | cut -d ' ' -f1)"
            ;;
        2)
            echo "Instalando SMAI (Servidores de Minecraft Automatizados Increíbles)..."
            # Ejecutar el script de instalación del servidor si existe
            if [ -f "install_server.sh" ]; then
                chmod +x install_server.sh
                ./install_server.sh
            else
                whiptail --title "Error" --msgbox "install_server.sh not found!" 8 45
            fi
            # Agregar al archivo de hosts solo si no existe
            add_to_ansible_hosts "servidor" "$(hostname -I | cut -d ' ' -f1)"
            ;;
        3)
            mensaje_exit
            exit 0
            ;;
        *)
            whiptail --title "Error" --msgbox "Invalid choice!" 8 45
            ;;
    esac
done
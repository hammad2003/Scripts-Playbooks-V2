#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Función para logging
log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

warning() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

mensaje_smai() {
    if command -v figlet &> /dev/null; then
        figlet "SMAI"
    else
        echo "================================"
        echo "           SMAI"
        echo "================================"
    fi
}

mensaje_exit() {
    if command -v figlet &> /dev/null; then
        figlet "Exiting..."
    else
        echo "Exiting..."
    fi
}

mensaje_password() {
    if command -v figlet &> /dev/null; then
        figlet "password"
    else
        echo "Enter password:"
    fi
}

# Función para instalar dependencias solo si no están instaladas
install_dependencies() {
    log "Verificando e instalando dependencias..."
    
    local packages=("openssh-server" "ansible" "sshpass" "whiptail" "figlet")
    local to_install=()
    
    for package in "${packages[@]}"; do
        if ! dpkg -l | grep -q "^ii  $package "; then
            to_install+=("$package")
        else
            log "$package ya está instalado"
        fi
    done
    
    if [ ${#to_install[@]} -gt 0 ]; then
        log "Instalando: ${to_install[*]}"
        sudo apt update
        sudo apt install -y "${to_install[@]}"
    else
        log "Todas las dependencias ya están instaladas"
    fi
}

# Función para configurar SSH
setup_ssh() {
    log "Configurando SSH..."
    
    # Verificar si ya existe la clave SSH
    if [ -f ~/.ssh/id_rsa ]; then
        warning "La clave SSH ya existe, omitiendo generación"
    else
        log "Generando nueva clave SSH..."
        ssh-keygen -t rsa -b 4096 -f ~/.ssh/id_rsa -N "" -q
    fi
    
    # Obtener IP local
    local ip_address=$(hostname -I | cut -d ' ' -f1)
    
    # Verificar si la clave ya está en authorized_keys
    if [ -f ~/.ssh/authorized_keys ] && grep -q "$(cat ~/.ssh/id_rsa.pub)" ~/.ssh/authorized_keys; then
        log "La clave SSH ya está autorizada"
    else
        log "Copiando clave SSH al servidor local..."
        mensaje_password
        ssh-copy-id -f -i ~/.ssh/id_rsa.pub usuario@$ip_address || {
            warning "No se pudo copiar la clave SSH automáticamente"
            log "Puedes hacerlo manualmente más tarde"
        }
    fi
}

# Función para configurar Ansible
setup_ansible() {
    log "Configurando Ansible..."
    
    # Crear directorio de Ansible si no existe
    if [ ! -d /etc/ansible ]; then
        sudo mkdir -p /etc/ansible
        log "Directorio /etc/ansible creado"
    fi
    
    # Crear archivo hosts si no existe
    if [ ! -f /etc/ansible/hosts ]; then
        sudo touch /etc/ansible/hosts
        log "Archivo /etc/ansible/hosts creado"
    fi
    
    # Configurar ansible.cfg
    configurar_ansible
}

# Función mejorada para agregar servidor al archivo de hosts de Ansible
add_to_ansible_hosts() {
    local server_type=$1
    local ip_address=$2
    
    log "Verificando configuración de Ansible hosts para $server_type..."
    
    # Verificar si la sección existe
    if ! grep -q "^\[$server_type\]" /etc/ansible/hosts; then
        log "Creando sección [$server_type] en Ansible hosts"
        {
            echo ""
            echo "[$server_type]"
            echo "$ip_address"
        } | sudo tee -a /etc/ansible/hosts > /dev/null
    else
        # Verificar si la IP ya está en la sección
        if ! sed -n "/^\[$server_type\]/,/^\[/p" /etc/ansible/hosts | grep -q "$ip_address"; then
            log "Agregando $ip_address a la sección [$server_type]"
            # Insertar la IP después de la línea de la sección
            sudo sed -i "/^\[$server_type\]/a $ip_address" /etc/ansible/hosts
        else
            log "$ip_address ya está en la sección [$server_type]"
        fi
    fi
    
    # Verificar que se añadió correctamente
    if grep -A 5 "^\[$server_type\]" /etc/ansible/hosts | grep -q "$ip_address"; then
        log "✅ IP $ip_address añadida correctamente a [$server_type]"
        return 0
    else
        error "❌ Error al añadir IP $ip_address a [$server_type]"
        return 1
    fi
}

# Nueva función para preparar Ansible antes de ejecutar playbooks
prepare_ansible_host() {
    local server_type=$1
    local ip_address=$(hostname -I | cut -d ' ' -f1)
    
    log "Preparando configuración de Ansible para $server_type..."
    
    # Añadir la IP al archivo hosts
    if add_to_ansible_hosts "$server_type" "$ip_address"; then
        log "Configuración de Ansible lista para $server_type"
        
        # Mostrar configuración actual para debug
        log "Configuración actual de /etc/ansible/hosts:"
        sudo cat /etc/ansible/hosts | tail -10
        
        return 0
    else
        error "Error al configurar Ansible hosts"
        return 1
    fi
}

# Función para crear archivo ansible.cfg si no existe y añadir configuración
configurar_ansible() {
    local config_file="/etc/ansible/ansible.cfg"
    
    if [ ! -f "$config_file" ]; then
        log "Creando configuración de Ansible..."
        {
            echo "[defaults]"
            echo "host_key_checking = False"
            echo "timeout = 30"
            echo "retry_files_enabled = False"
        } | sudo tee "$config_file" > /dev/null
    else
        # Verificar si la configuración ya existe
        if ! grep -q "host_key_checking = False" "$config_file"; then
            log "Actualizando configuración de Ansible..."
            echo "host_key_checking = False" | sudo tee -a "$config_file" > /dev/null
        fi
    fi
}

# Función principal
main() {
    mensaje_smai
    
    # Verificar si se ejecuta como root
    if [ "$EUID" -eq 0 ]; then
        error "No ejecutes este script como root"
        exit 1
    fi
    
    # Instalar dependencias
    install_dependencies
    
    # Configurar SSH
    setup_ssh
    
    # Configurar Ansible
    setup_ansible
    
    # Menú principal
    while true; do
        CHOICE=$(whiptail --title "SMAI - Script Selection Menu" --menu "Choose a script to run:" 15 60 4 \
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
                log "Preparando instalación de TLauncher (Cliente)..."
        
                # Preparar Ansible antes de ejecutar
                if prepare_ansible_host "clientes"; then
                    if [ -f "install_client.sh" ]; then
                        chmod +x install_client.sh
                        ./install_client.sh
                        if [ $? -eq 0 ]; then
                            whiptail --title "Éxito" --msgbox "Cliente instalado correctamente!" 8 45
                        else
                            whiptail --title "Error" --msgbox "Error al instalar el cliente!" 8 45
                        fi
                    else
                        whiptail --title "Error" --msgbox "install_client.sh not found!" 8 45
                    fi
                else
                    whiptail --title "Error" --msgbox "Error al configurar Ansible para cliente!" 8 45
                fi
                ;;
            2)
                log "Preparando instalación de SMAI (Servidor)..."
        
                # Preparar Ansible antes de ejecutar
                if prepare_ansible_host "servidor"; then
                    if [ -f "install_server.sh" ]; then
                        chmod +x install_server.sh
                        ./install_server.sh
                        if [ $? -eq 0 ]; then
                            whiptail --title "Éxito" --msgbox "Servidor instalado correctamente!" 8 45
                        else
                            whiptail --title "Error" --msgbox "Error al instalar el servidor!" 8 45
                        fi
                    else
                        whiptail --title "Error" --msgbox "install_server.sh not found!" 8 45
                    fi
                else
                    whiptail --title "Error" --msgbox "Error al configurar Ansible para servidor!" 8 45
                fi
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
}

# Ejecutar función principal
main "$@"

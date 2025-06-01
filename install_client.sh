#!/bin/bash

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

log() {
    echo -e "${GREEN}[$(date +'%Y-%m-%d %H:%M:%S')] $1${NC}"
}

error() {
    echo -e "${RED}[ERROR] $1${NC}"
}

mensaje_smai() {
    if command -v figlet &> /dev/null; then
        figlet "SMAI    CLIENT"
    else
        echo "================================"
        echo "       SMAI CLIENT"
        echo "================================"
    fi
}

mensaje_password() {
    if command -v figlet &> /dev/null; then
        figlet "password"
    else
        echo "Enter password:"
    fi
}

main() {
    mensaje_smai
    
    # Verificar que Ansible esté instalado
    if ! command -v ansible-playbook &> /dev/null; then
        error "Ansible no está instalado. Ejecuta run.sh primero."
        exit 1
    fi
    
    # Verificar que el archivo de configuración existe
    if [ ! -f "configuration_client.yml" ]; then
        error "configuration_client.yml no encontrado!"
        exit 1
    fi
    
    # Verificar que la IP está en el archivo hosts de Ansible
    local ip_address=$(hostname -I | cut -d ' ' -f1)
    if ! grep -A 5 "^\[clientes\]" /etc/ansible/hosts | grep -q "$ip_address"; then
        error "La IP $ip_address no está configurada en /etc/ansible/hosts para clientes"
        log "Configuración actual de /etc/ansible/hosts:"
        sudo cat /etc/ansible/hosts
        exit 1
    fi
    
    log "Iniciando configuración del cliente..."
    log "IP detectada: $ip_address"
    mensaje_password
    
    # Ejecutar playbook con mejor manejo de errores
    if ansible-playbook configuration_client.yml -k -b -K --timeout=300 -v; then
        log "Cliente configurado exitosamente!"
        log "TLauncher instalado en: /home/usuario/smai/launcher/"
        exit 0
    else
        error "Error al configurar el cliente"
        log "Verificando logs de Ansible..."
        exit 1
    fi
}

main "$@"

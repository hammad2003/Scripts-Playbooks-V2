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
    
    log "Iniciando configuración del cliente..."
    mensaje_password
    
    # Ejecutar playbook con mejor manejo de errores
    if ansible-playbook configuration_client.yml -k -b -K --timeout=300; then
        log "Cliente configurado exitosamente!"
        log "TLauncher instalado en: /home/usuario/smai/launcher/"
        exit 0
    else
        error "Error al configurar el cliente"
        exit 1
    fi
}

main "$@"

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
        figlet "SMAI    SERVER"
    else
        echo "================================"
        echo "       SMAI SERVER"
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
    if [ ! -f "configuration_server.yml" ]; then
        error "configuration_server.yml no encontrado!"
        exit 1
    fi
    
    log "Iniciando configuración del servidor..."
    mensaje_password
    
    # Ejecutar playbook con mejor manejo de errores
    if ansible-playbook configuration_server.yml -k -b -K --timeout=300; then
        log "Servidor configurado exitosamente!"
        echo ""
        log "El servidor SMAI está disponible en:"
        log "Frontend: http://$(hostname -I | cut -d ' ' -f1):5173"
        log "Backend: http://$(hostname -I | cut -d ' ' -f1):5000"
        exit 0
    else
        error "Error al configurar el servidor"
        exit 1
    fi
}

main "$@"

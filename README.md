# 🚀 smaiV2 - Scripts-Playbooks-V2

**Servidores de Minecraft Automatizados Increíbles**

Scripts de automatización con Ansible para la instalación completa del proyecto [smaiV2](https://github.com/McMiguel2004/smaiV2) - Una plataforma web para gestionar servidores de Minecraft con Docker.

## 📋 Descripción

Este repositorio contiene scripts de Ansible que automatizan completamente la instalación y configuración de SMAI, incluyendo:

- ✅ **Backend Python** (Flask)
- ✅ **Frontend React** (Vite)
- ✅ **Base de datos PostgreSQL**
- ✅ **Docker** para servidores de Minecraft
- ✅ **Servicios systemd** para auto-inicio
- ✅ **Cliente TLauncher** (opcional)

## 🎯 Características

- **🔄 Instalación completamente automatizada**
- **🔧 Configuración idempotente** (se puede ejecutar múltiples veces)
- **🛡️ Manejo robusto de errores**
- **📊 Base de datos preconfigurada** con esquemas y permisos
- **🚀 Servicios auto-iniciables** con systemd
- **🎮 Soporte para cliente y servidor**

## 📦 Requisitos del Sistema

### Sistema Operativo
- **Ubuntu 22.04**
- Acceso **sudo**
- Usuario **\`usuario\`** (configurable)

### Dependencias (se instalan automáticamente)
- Ansible
- SSH Server
- Python 3.8+
- Node.js 18 (via NVM)
- PostgreSQL
- Docker

## 🚀 Instalación Rápida

### 1. Clonar el repositorio
```bash
git clone https://github.com/hammad2003/Scripts-Playbooks-V2
cd Scripts-Playbooks-V2
```

### 2. Ejecutar el script principal
```bash
chmod +x run.sh
./run.sh
```

### 3. Seleccionar opción en el menú
- **Opción 1:** Instalar TLauncher (Cliente)
- **Opción 2:** Instalar SMAI (Servidor)

## 📁 Estructura del Proyecto

```

Scripts-Playbooks-V2/
├── run.sh                    # Script principal con menú interactivo
├── install_server.sh         # Instalador del servidor SMAI
├── install_client.sh         # Instalador del cliente TLauncher
├── configuration_server.yml  # Playbook de Ansible para servidor
├── configuration_client.yml  # Playbook de Ansible para cliente
└── README.md                # Este archivo
```

## 🔧 Configuración Detallada

### Variables del Servidor
Las siguientes variables se pueden modificar en \`configuration_server.yml\`:

```yaml
vars:
  db_name: smai                    # Nombre de la base de datos
  db_user: usuario                 # Usuario de la base de datos
  db_password: usuario             # Contraseña de la base de datos
  project_dir: /home/usuario/smaiV2 # Directorio del proyecto
  github_repo: https://github.com/McMiguel2004/smaiV2.git
```

### Puertos Utilizados
- **Frontend (React/Vite):** 5173
- **Backend (Flask):** 5000
- **PostgreSQL:** 5432

## 🎮 Uso del Sistema

### Acceso a la Aplicación
Una vez instalado, SMAI estará disponible en:

- **Frontend:** \`http://TU_IP:5173\`
- **Backend API:** \`http://TU_IP:5000\`

### Gestión de Servicios

```bash
# Ver estado de los servicios
sudo systemctl status smai-backend
sudo systemctl status smai-frontend

# Reiniciar servicios
sudo systemctl restart smai-backend
sudo systemctl restart smai-frontend

# Ver logs en tiempo real
sudo journalctl -u smai-backend -f
sudo journalctl -u smai-frontend -f
```

## 🗄️ Base de Datos

### Esquema Automático
El script crea automáticamente:

- **Tipos ENUM:** \`difficulty_enum\`, \`mode_enum\`
- **Tablas:** \`users\`, \`servers\`, \`server_properties\`, \`wireguard_configs\`
- **Permisos:** Usuario \`usuario\` con acceso completo

### Conexión Manual
```bash
sudo -u postgres psql -d smai
```

## 🐛 Solución de Problemas

### Errores Comunes (Normales)

#### ❌ "Database is being accessed by other users"
**Causa:** La base de datos está en uso por el backend
**Solución:** Este error se ignora automáticamente ✅

#### ❌ "Unable to remove user"
**Causa:** El usuario de BD ya existe y está conectado
**Solución:** Este error se ignora automáticamente ✅

### Verificación de Instalación

```bash
# Verificar que los servicios están activos
systemctl is-active smai-backend smai-frontend

# Verificar que los puertos están abiertos
netstat -tlnp | grep -E ':(5000|5173)'

# Verificar logs de errores
journalctl -u smai-backend --since "1 hour ago"
journalctl -u smai-frontend --since "1 hour ago"
```

### Reinstalación Completa

```bash
# Detener servicios
sudo systemctl stop smai-backend smai-frontend

# Ejecutar el script nuevamente
./run.sh
```

## 🔄 Re-ejecución Segura

Los scripts están diseñados para ser **idempotentes**:
- ✅ Se pueden ejecutar múltiples veces sin problemas
- ✅ Detectan automáticamente componentes ya instalados
- ✅ Actualizan configuraciones cuando es necesario
- ✅ Preservan datos existentes

## 🤝 Contribuir

1. Fork el proyecto
2. Crea una rama para tu feature (\`git checkout -b feature/AmazingFeature\`)
3. Commit tus cambios (\`git commit -m 'Add some AmazingFeature'\`)
4. Push a la rama (\`git push origin feature/AmazingFeature\`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT. Ver el archivo \`LICENSE\` para más detalles.

## 🙏 Agradecimientos

- [McMiguel2004](https://github.com/McMiguel2004) por el proyecto original [smaiV2](https://github.com/McMiguel2004/smaiV2)
- Comunidad de Ansible por las herramientas de automatización
- Comunidad de Minecraft por la inspiración

## 📞 Soporte

Si tienes problemas o preguntas:

1. **Revisa la sección de solución de problemas** arriba
2. **Verifica los logs** de los servicios
3. **Abre un issue** en este repositorio con:
   - Descripción del problema
   - Logs relevantes
   - Información del sistema

---

**⭐ Si este proyecto te ayudó, considera darle una estrella en GitHub**

```bash
# Comando rápido para verificar que todo funciona
curl -s http://localhost:5000 && curl -s http://localhost:5173
```

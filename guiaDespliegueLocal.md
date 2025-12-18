# Guía de Despliegue Local en 3 Nodos - Arquitectura de 3 Capas

## 📚 Índice

1. [Introducción](#introducción)
2. [Arquitectura de Despliegue](#arquitectura-de-despliegue)
3. [Requisitos Previos](#requisitos-previos)
4. [Configuración del Nodo 1: Base de Datos (Tier 3)](#configuración-del-nodo-1-base-de-datos-tier-3)
5. [Configuración del Nodo 2: Backend (Tier 2)](#configuración-del-nodo-2-backend-tier-2)
6. [Configuración del Nodo 3: Frontend (Tier 1)](#configuración-del-nodo-3-frontend-tier-1)
7. [Verificación y Pruebas](#verificación-y-pruebas)
8. [Solución de Problemas](#solución-de-problemas)
9. [Configuración Avanzada](#configuración-avanzada)

---

## Introducción

Esta guía te enseñará cómo desplegar la aplicación en **3 nodos físicos diferentes**, uno para cada capa de la arquitectura de 3 tiers. Esto demuestra la verdadera separación física de las capas y permite escalar cada tier independientemente.

### Objetivos de Aprendizaje

- ✅ Entender cómo desplegar cada capa en un servidor independiente
- ✅ Configurar comunicación entre tiers a través de red
- ✅ Demostrar la separación física de responsabilidades
- ✅ Aprender configuración de red y firewall básico

---

## Arquitectura de Despliegue

### Diagrama de Red

```
┌─────────────────────────────────────────────────────────┐
│                    RED LOCAL                            │
│                                                         │
│  ┌─────────────────┐    ┌─────────────────┐          │
│  │   NODO 1        │    │   NODO 2        │          │
│  │   Tier 3        │    │   Tier 2        │          │
│  │   Database      │◄───┤   Backend       │          │
│  │   IP: 192.168.1.10│    │   IP: 192.168.1.20│          │
│  │   Puerto: 5432  │    │   Puerto: 5001  │          │
│  └─────────────────┘    └────────┬────────┘          │
│                                   │                    │
│                                   │ HTTP/REST          │
│                                   ▼                    │
│                          ┌─────────────────┐          │
│                          │   NODO 3        │          │
│                          │   Tier 1        │          │
│                          │   Frontend      │          │
│                          │   IP: 192.168.1.30│          │
│                          │   Puerto: 3001  │          │
│                          └─────────────────┘          │
│                                                         │
└─────────────────────────────────────────────────────────┘
```

### Especificaciones de los Nodos

| Nodo | Capa | IP | Puerto | Servicios |
|------|------|----|--------|-----------|
| Nodo 1 | Tier 3 (Database) | 192.168.1.10 | 5432 | PostgreSQL |
| Nodo 2 | Tier 2 (Backend) | 192.168.1.20 | 5001 | Flask API |
| Nodo 3 | Tier 1 (Frontend) | 192.168.1.30 | 3001 | React App |

**Nota**: Las IPs son ejemplos. Ajusta según tu configuración de red local.

---

## Requisitos Previos

### Para Cada Nodo

- **Sistema Operativo**: Linux (Ubuntu 20.04+ recomendado) o macOS
- **Acceso SSH**: Capacidad de conectarse remotamente a cada nodo
- **Red**: Todos los nodos deben estar en la misma red local
- **Permisos**: Acceso de administrador (sudo) en cada nodo

### Software Necesario por Nodo

**Nodo 1 (Database)**:
- PostgreSQL 12+ o MySQL 8+

**Nodo 2 (Backend)**:
- Python 3.8+
- pip
- Git

**Nodo 3 (Frontend)**:
- Node.js 14+
- npm
- Git

---

## Configuración del Nodo 1: Base de Datos (Tier 3)

### Paso 1: Instalar PostgreSQL

```bash
# Conectarse al Nodo 1
ssh usuario@192.168.1.10

# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar PostgreSQL
sudo apt install postgresql postgresql-contrib -y

# Verificar instalación
sudo systemctl status postgresql
```

### Paso 2: Configurar PostgreSQL

```bash
# Cambiar al usuario postgres
sudo -u postgres psql

# Crear base de datos y usuario
CREATE DATABASE limpieza_empresas;
CREATE USER limpieza_user WITH PASSWORD 'contraseña_segura_123';
GRANT ALL PRIVILEGES ON DATABASE limpieza_empresas TO limpieza_user;
ALTER USER limpieza_user CREATEDB;
\q
```

### Paso 3: Configurar Acceso Remoto

```bash
# Editar configuración de PostgreSQL
sudo nano /etc/postgresql/15/main/postgresql.conf

# Buscar y modificar:
listen_addresses = '*'  # En lugar de 'localhost'
```

```bash
# Configurar pg_hba.conf para permitir conexiones remotas
sudo nano /etc/postgresql/15/main/pg_hba.conf

# Agregar al final del archivo:
host    limpieza_empresas    limpieza_user    192.168.1.0/24    md5
```

### Paso 4: Reiniciar PostgreSQL

```bash
sudo systemctl restart postgresql
sudo systemctl enable postgresql

# Verificar que está escuchando en todas las interfaces
sudo netstat -tulpn | grep 5432
```

### Paso 5: Configurar Firewall (si aplica)

```bash
# Permitir conexiones PostgreSQL desde la red local
sudo ufw allow from 192.168.1.0/24 to any port 5432
sudo ufw enable
sudo ufw status
```

### Paso 6: Crear Esquema de Base de Datos

```bash
# Desde el Nodo 2 o tu máquina local, ejecutar el script de inicialización
# Primero, instalar psql en el Nodo 2 o usar el script Python

# O crear el esquema manualmente desde el Nodo 1:
sudo -u postgres psql limpieza_empresas

# Ejecutar el contenido de database/schema.sql
CREATE TABLE IF NOT EXISTS empresas (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    direccion VARCHAR(200) NOT NULL,
    telefono VARCHAR(20) NOT NULL,
    email VARCHAR(100) NOT NULL
);

CREATE TABLE IF NOT EXISTS servicios (
    id SERIAL PRIMARY KEY,
    nombre VARCHAR(100) NOT NULL,
    descripcion TEXT,
    precio_base REAL NOT NULL,
    duracion_horas REAL NOT NULL
);

CREATE TABLE IF NOT EXISTS contratos (
    id SERIAL PRIMARY KEY,
    empresa_id INTEGER NOT NULL,
    servicio_id INTEGER NOT NULL,
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE,
    estado VARCHAR(20) NOT NULL DEFAULT 'activo',
    precio_final REAL NOT NULL,
    FOREIGN KEY (empresa_id) REFERENCES empresas(id) ON DELETE CASCADE,
    FOREIGN KEY (servicio_id) REFERENCES servicios(id) ON DELETE CASCADE
);

\q
```

### Paso 7: Verificar Conexión Remota

```bash
# Desde el Nodo 2, probar conexión:
psql -h 192.168.1.10 -U limpieza_user -d limpieza_empresas

# Si funciona, verás el prompt de PostgreSQL
```

---

## Configuración del Nodo 2: Backend (Tier 2)

### Paso 1: Preparar el Entorno

```bash
# Conectarse al Nodo 2
ssh usuario@192.168.1.20

# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Python y herramientas
sudo apt install python3 python3-pip python3-venv git -y

# Instalar cliente PostgreSQL (para pruebas)
sudo apt install postgresql-client -y
```

### Paso 2: Clonar el Repositorio

```bash
# Crear directorio para la aplicación
mkdir -p /opt/limpieza
cd /opt/limpieza

# Clonar repositorio (o copiar archivos)
git clone https://github.com/tu-usuario/arqCS-NCapas.git
# O copiar archivos manualmente con scp
cd arqCS-NCapas/backend
```

### Paso 3: Configurar Entorno Virtual

```bash
# Crear entorno virtual
python3 -m venv venv

# Activar entorno virtual
source venv/bin/activate

# Instalar dependencias
pip install --upgrade pip
pip install -r requirements.txt

# Instalar dependencia adicional para PostgreSQL
pip install psycopg2-binary
```

### Paso 4: Configurar Variables de Entorno

```bash
# Crear archivo .env
nano .env
```

**Contenido del archivo `.env`**:

```env
FLASK_ENV=production
SQLALCHEMY_DATABASE_URI=postgresql://limpieza_user:contraseña_segura_123@192.168.1.10:5432/limpieza_empresas
PORT=5001
SECRET_KEY=tu-clave-secreta-super-segura-aqui
CORS_ORIGINS=http://192.168.1.30:3001,http://localhost:3001
```

### Paso 5: Actualizar Código para Usar Variables de Entorno

```bash
# Editar backend/app/__init__.py
nano app/__init__.py
```

Agregar al inicio del archivo:

```python
import os
from dotenv import load_dotenv

load_dotenv()

def create_app():
    app = Flask(__name__)
    
    # Usar variable de entorno o valor por defecto
    app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv(
        'SQLALCHEMY_DATABASE_URI',
        'sqlite:///limpieza_empresas.db'
    )
    app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-secret-key')
    
    # Configurar CORS
    cors_origins = os.getenv('CORS_ORIGINS', 'http://localhost:3001').split(',')
    CORS(app, resources={
        r"/api/*": {"origins": cors_origins}
    })
    
    # ... resto del código
```

### Paso 6: Actualizar requirements.txt

```bash
# Agregar python-dotenv y psycopg2-binary
echo "python-dotenv==1.0.0" >> requirements.txt
echo "psycopg2-binary==2.9.9" >> requirements.txt

# Reinstalar
pip install -r requirements.txt
```

### Paso 7: Inicializar Base de Datos

```bash
# Asegúrate de que el entorno virtual esté activado
source venv/bin/activate

# Ejecutar script de inicialización
cd ../database
python3 init_db.py

# O crear las tablas manualmente
cd ../backend
python3 -c "from app import create_app; from app.config.database import init_db; app = create_app(); init_db(app)"
```

### Paso 8: Configurar como Servicio Systemd

```bash
# Crear archivo de servicio
sudo nano /etc/systemd/system/limpieza-backend.service
```

**Contenido del servicio**:

```ini
[Unit]
Description=Limpieza Backend Service (Tier 2)
After=network.target postgresql.service

[Service]
Type=simple
User=www-data
WorkingDirectory=/opt/limpieza/arqCS-NCapas/backend
Environment="PATH=/opt/limpieza/arqCS-NCapas/backend/venv/bin"
EnvironmentFile=/opt/limpieza/arqCS-NCapas/backend/.env
ExecStart=/opt/limpieza/arqCS-NCapas/backend/venv/bin/python run.py
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
```

```bash
# Recargar systemd
sudo systemctl daemon-reload

# Habilitar servicio
sudo systemctl enable limpieza-backend

# Iniciar servicio
sudo systemctl start limpieza-backend

# Verificar estado
sudo systemctl status limpieza-backend

# Ver logs
sudo journalctl -u limpieza-backend -f
```

### Paso 9: Configurar Firewall

```bash
# Permitir puerto 5001 desde la red local
sudo ufw allow from 192.168.1.0/24 to any port 5001
sudo ufw enable
sudo ufw status
```

### Paso 10: Verificar que el Backend Funciona

```bash
# Desde el Nodo 3 o tu máquina local
curl http://192.168.1.20:5001/

# Deberías ver:
# {"message": "API de Servicios de Limpieza para Empresas", "version": "1.0"}
```

---

## Configuración del Nodo 3: Frontend (Tier 1)

### Paso 1: Preparar el Entorno

```bash
# Conectarse al Nodo 3
ssh usuario@192.168.1.30

# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Node.js y npm
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install -y nodejs

# Verificar instalación
node --version
npm --version

# Instalar Git
sudo apt install git -y
```

### Paso 2: Clonar el Repositorio

```bash
# Crear directorio para la aplicación
mkdir -p /opt/limpieza
cd /opt/limpieza

# Clonar repositorio
git clone https://github.com/tu-usuario/arqCS-NCapas.git
cd arqCS-NCapas/frontend
```

### Paso 3: Instalar Dependencias

```bash
# Instalar dependencias de npm
npm install

# Si hay problemas, limpiar e instalar de nuevo
rm -rf node_modules package-lock.json
npm install
```

### Paso 4: Configurar Variables de Entorno

```bash
# Crear archivo .env
nano .env
```

**Contenido del archivo `.env`**:

```env
REACT_APP_API_URL=http://192.168.1.20:5001/api
PORT=3001
```

### Paso 5: Construir la Aplicación para Producción

```bash
# Construir aplicación React
npm run build

# Verificar que se creó el directorio build/
ls -la build/
```

### Paso 6: Instalar y Configurar Nginx

```bash
# Instalar Nginx
sudo apt install nginx -y

# Crear configuración para la aplicación
sudo nano /etc/nginx/sites-available/limpieza-frontend
```

**Contenido de la configuración de Nginx**:

```nginx
server {
    listen 3001;
    server_name 192.168.1.30;

    root /opt/limpieza/arqCS-NCapas/frontend/build;
    index index.html;

    # Configuración para React Router
    location / {
        try_files $uri $uri/ /index.html;
    }

    # Configuración de archivos estáticos
    location /static {
        alias /opt/limpieza/arqCS-NCapas/frontend/build/static;
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Headers de seguridad
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
}
```

```bash
# Habilitar sitio
sudo ln -s /etc/nginx/sites-available/limpieza-frontend /etc/nginx/sites-enabled/

# Verificar configuración
sudo nginx -t

# Reiniciar Nginx
sudo systemctl restart nginx
sudo systemctl enable nginx

# Verificar estado
sudo systemctl status nginx
```

### Paso 7: Configurar Firewall

```bash
# Permitir puerto 3001 desde la red local
sudo ufw allow from 192.168.1.0/24 to any port 3001
sudo ufw allow 'Nginx Full'
sudo ufw enable
sudo ufw status
```

### Paso 8: Verificar que el Frontend Funciona

```bash
# Desde tu navegador o con curl
curl http://192.168.1.30:3001/

# Deberías ver el HTML de la aplicación React
```

### Opción Alternativa: Usar PM2 para Desarrollo

Si prefieres ejecutar el servidor de desarrollo de React:

```bash
# Instalar PM2 globalmente
sudo npm install -g pm2

# Crear archivo ecosystem.config.js
nano ecosystem.config.js
```

**Contenido**:

```javascript
module.exports = {
  apps: [{
    name: 'limpieza-frontend',
    script: 'npm',
    args: 'start',
    cwd: '/opt/limpieza/arqCS-NCapas/frontend',
    env: {
      PORT: 3001,
      REACT_APP_API_URL: 'http://192.168.1.20:5001/api'
    },
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G'
  }]
};
```

```bash
# Iniciar con PM2
pm2 start ecosystem.config.js

# Guardar configuración
pm2 save

# Configurar PM2 para iniciar al arrancar el sistema
pm2 startup
# Ejecutar el comando que PM2 te muestre

# Ver estado
pm2 status
pm2 logs limpieza-frontend
```

---

## Verificación y Pruebas

### Paso 1: Verificar Conectividad entre Nodos

```bash
# Desde Nodo 2, verificar conexión a Nodo 1 (Database)
psql -h 192.168.1.10 -U limpieza_user -d limpieza_empresas -c "SELECT version();"

# Desde Nodo 3, verificar conexión a Nodo 2 (Backend)
curl http://192.168.1.20:5001/api/empresas

# Desde tu máquina local, verificar todos los servicios
curl http://192.168.1.10:5432  # Debería fallar (PostgreSQL no responde HTTP)
curl http://192.168.1.20:5001/  # Debería funcionar
curl http://192.168.1.30:3001/  # Debería funcionar
```

### Paso 2: Probar Flujo Completo

1. **Abrir navegador** en `http://192.168.1.30:3001`
2. **Crear una empresa** desde el frontend
3. **Verificar en la base de datos**:
   ```bash
   psql -h 192.168.1.10 -U limpieza_user -d limpieza_empresas
   SELECT * FROM empresas;
   ```
4. **Verificar logs del backend**:
   ```bash
   sudo journalctl -u limpieza-backend -f
   ```

### Paso 3: Monitoreo Básico

```bash
# Ver procesos en cada nodo
# Nodo 1 (Database)
sudo systemctl status postgresql

# Nodo 2 (Backend)
sudo systemctl status limpieza-backend
sudo journalctl -u limpieza-backend --since "10 minutes ago"

# Nodo 3 (Frontend)
sudo systemctl status nginx
# O si usas PM2:
pm2 status
pm2 logs
```

---

## Solución de Problemas

### Problema: No puedo conectar desde Nodo 2 a Nodo 1

```bash
# Verificar que PostgreSQL está escuchando
sudo netstat -tulpn | grep 5432

# Verificar configuración de listen_addresses
sudo grep listen_addresses /etc/postgresql/15/main/postgresql.conf

# Verificar pg_hba.conf
sudo cat /etc/postgresql/15/main/pg_hba.conf | grep limpieza

# Verificar firewall
sudo ufw status | grep 5432

# Probar conexión local primero
psql -h localhost -U limpieza_user -d limpieza_empresas
```

### Problema: CORS Error en el Frontend

```bash
# Verificar que CORS_ORIGINS incluye la IP del frontend
cat /opt/limpieza/arqCS-NCapas/backend/.env | grep CORS

# Reiniciar backend
sudo systemctl restart limpieza-backend

# Verificar logs
sudo journalctl -u limpieza-backend | tail -20
```

### Problema: Frontend no puede conectar al Backend

```bash
# Verificar que el backend está corriendo
curl http://192.168.1.20:5001/

# Verificar variable de entorno en frontend
cat /opt/limpieza/arqCS-NCapas/frontend/.env

# Verificar que el build incluye la variable correcta
grep -r "192.168.1.20" /opt/limpieza/arqCS-NCapas/frontend/build/

# Reconstruir frontend si es necesario
cd /opt/limpieza/arqCS-NCapas/frontend
npm run build
sudo systemctl restart nginx
```

### Problema: Servicios no inician al arrancar

```bash
# Verificar que los servicios están habilitados
sudo systemctl is-enabled postgresql
sudo systemctl is-enabled limpieza-backend
sudo systemctl is-enabled nginx

# Habilitar si no lo están
sudo systemctl enable postgresql
sudo systemctl enable limpieza-backend
sudo systemctl enable nginx
```

---

## Configuración Avanzada

### Configurar SSL/TLS (Opcional)

Para producción, considera agregar HTTPS:

```bash
# Instalar Certbot
sudo apt install certbot python3-certbot-nginx -y

# Obtener certificado (requiere dominio)
sudo certbot --nginx -d tu-dominio.com
```

### Configurar Balanceador de Carga

Si tienes múltiples instancias del backend:

```bash
# En Nginx del frontend, agregar upstream
upstream backend_servers {
    server 192.168.1.20:5001;
    server 192.168.1.21:5001;  # Segundo backend
}

# En la configuración de Nginx
location /api {
    proxy_pass http://backend_servers;
    proxy_set_header Host $host;
    proxy_set_header X-Real-IP $remote_addr;
}
```

### Monitoreo con Logs Centralizados

```bash
# Configurar rsyslog para enviar logs a un servidor central
# O usar herramientas como ELK Stack, Grafana, etc.
```

### Backup Automático de Base de Datos

```bash
# Crear script de backup
sudo nano /opt/scripts/backup-db.sh
```

```bash
#!/bin/bash
BACKUP_DIR="/opt/backups"
DATE=$(date +%Y%m%d_%H%M%S)
pg_dump -h 192.168.1.10 -U limpieza_user limpieza_empresas > $BACKUP_DIR/backup_$DATE.sql

# Programar con cron
sudo crontab -e
# Agregar: 0 2 * * * /opt/scripts/backup-db.sh
```

---

## Checklist de Despliegue

### Nodo 1 (Database)
- [ ] PostgreSQL instalado y corriendo
- [ ] Base de datos creada
- [ ] Usuario creado con permisos
- [ ] Acceso remoto configurado
- [ ] Firewall configurado
- [ ] Esquema de tablas creado
- [ ] Conexión remota probada

### Nodo 2 (Backend)
- [ ] Python y dependencias instaladas
- [ ] Código del backend copiado
- [ ] Entorno virtual creado
- [ ] Variables de entorno configuradas
- [ ] Conexión a base de datos probada
- [ ] Servicio systemd configurado
- [ ] Backend corriendo y accesible
- [ ] Firewall configurado
- [ ] Logs funcionando

### Nodo 3 (Frontend)
- [ ] Node.js instalado
- [ ] Código del frontend copiado
- [ ] Dependencias instaladas
- [ ] Variables de entorno configuradas
- [ ] Build de producción creado
- [ ] Nginx configurado (o PM2)
- [ ] Frontend accesible desde navegador
- [ ] Firewall configurado
- [ ] Conexión al backend probada

### Verificación Final
- [ ] Flujo completo probado (crear empresa, servicio, contrato)
- [ ] Logs verificados en cada nodo
- [ ] Servicios configurados para iniciar al arrancar
- [ ] Documentación de IPs y credenciales guardada

---

## Comandos de Referencia Rápida

### Nodo 1 (Database)

```bash
# Iniciar/Detener PostgreSQL
sudo systemctl start postgresql
sudo systemctl stop postgresql
sudo systemctl restart postgresql

# Ver logs
sudo journalctl -u postgresql -f

# Conectar a base de datos
sudo -u postgres psql limpieza_empresas
```

### Nodo 2 (Backend)

```bash
# Iniciar/Detener Backend
sudo systemctl start limpieza-backend
sudo systemctl stop limpieza-backend
sudo systemctl restart limpieza-backend

# Ver logs
sudo journalctl -u limpieza-backend -f

# Verificar estado
sudo systemctl status limpieza-backend
```

### Nodo 3 (Frontend)

```bash
# Reiniciar Nginx
sudo systemctl restart nginx

# Ver logs de Nginx
sudo tail -f /var/log/nginx/error.log
sudo tail -f /var/log/nginx/access.log

# Si usas PM2
pm2 restart limpieza-frontend
pm2 logs limpieza-frontend
```

---

## Conclusión

Con esta configuración, has desplegado exitosamente la aplicación en **3 nodos físicos separados**, demostrando:

- ✅ **Separación física** de las capas
- ✅ **Escalabilidad independiente** de cada tier
- ✅ **Comunicación por red** entre tiers
- ✅ **Configuración de servicios** del sistema
- ✅ **Seguridad básica** con firewall

Cada tier puede ahora:
- Escalarse independientemente (múltiples instancias del backend)
- Actualizarse sin afectar otros tiers
- Desplegarse en diferentes ubicaciones físicas
- Configurarse con diferentes niveles de seguridad

**Próximos pasos**:
- Configurar monitoreo y alertas
- Implementar backups automáticos
- Configurar SSL/TLS para producción
- Considerar balanceadores de carga para alta disponibilidad

¡Felicitaciones por completar el despliegue en 3 nodos! 🎉


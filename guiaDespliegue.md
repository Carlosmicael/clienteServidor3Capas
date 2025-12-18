# Guía de Despliegue - Aplicación Cliente-Servidor y 3 Capas

## 📚 Índice

1. [Requisitos Previos](#requisitos-previos)
2. [Despliegue Local](#despliegue-local)
3. [Despliegue con Docker](#despliegue-con-docker)
4. [Despliegue en Producción](#despliegue-en-producción)
5. [Despliegue por Tiers Separados](#despliegue-por-tiers-separados)
6. [Configuración de Variables de Entorno](#configuración-de-variables-de-entorno)
7. [Solución de Problemas](#solución-de-problemas)
8. [Checklist de Despliegue](#checklist-de-despliegue)

---

## Requisitos Previos

### Para Despliegue Local (Sin Docker)

- **Python 3.8+** instalado
- **Node.js 14+** y **npm** instalados
- **Git** para clonar el repositorio

### Para Despliegue con Docker

- **Docker** instalado (versión 20.10+)
- **Docker Compose** instalado (versión 1.29+)

### Verificar Instalaciones

```bash
# Verificar Python
python3 --version

# Verificar Node.js
node --version
npm --version

# Verificar Docker
docker --version
docker compose version
```

---

## Despliegue Local

### Opción 1: Usando el Script run.sh (Recomendado)

El proyecto incluye un script automatizado que facilita el despliegue:

```bash
# Dar permisos de ejecución (solo la primera vez)
chmod +x run.sh

# Instalar todas las dependencias
./run.sh install

# Ejecutar backend y frontend
./run.sh backend    # En una terminal
./run.sh frontend   # En otra terminal
```

### Opción 2: Despliegue Manual

#### Paso 1: Clonar el Repositorio

```bash
git clone <url-del-repositorio>
cd arqCS-NCapas
```

#### Paso 2: Configurar Backend (Tier 2)

```bash
cd backend

# Crear entorno virtual
python3 -m venv venv

# Activar entorno virtual
# En Linux/macOS:
source venv/bin/activate
# En Windows:
venv\Scripts\activate

# Instalar dependencias
pip install --upgrade pip
pip install -r requirements.txt

# Inicializar base de datos (opcional)
cd ../database
python init_db.py
cd ../backend

# Ejecutar servidor
python run.py
```

El backend estará disponible en `http://localhost:5001`

#### Paso 3: Configurar Frontend (Tier 1)

```bash
# En una nueva terminal
cd frontend

# Instalar dependencias
npm install

# Ejecutar servidor de desarrollo
PORT=3001 npm start
```

El frontend estará disponible en `http://localhost:3001`

---

## Despliegue con Docker

### Opción 1: Docker Compose (Recomendado para Desarrollo)

```bash
# Construir y ejecutar todos los servicios
docker compose up --build

# Ejecutar en segundo plano
docker compose up -d --build

# Ver logs
docker compose logs -f

# Detener servicios
docker compose down

# Detener y eliminar volúmenes
docker compose down -v
```

### Opción 2: Usando el Script run.sh

```bash
# Ejecutar con Docker
./run.sh docker

# Ver logs
./run.sh logs

# Detener servicios
./run.sh stop
```

### Opción 3: Construcción Manual de Imágenes

#### Construir Imagen del Backend

```bash
cd backend
docker build -t limpieza-backend:latest .

# Ejecutar contenedor
docker run -d \
  --name limpieza-backend \
  -p 5001:5001 \
  -e PORT=5001 \
  limpieza-backend:latest
```

#### Construir Imagen del Frontend

```bash
cd frontend
docker build -t limpieza-frontend:latest .

# Ejecutar contenedor
docker run -d \
  --name limpieza-frontend \
  -p 3001:3001 \
  -e PORT=3001 \
  -e REACT_APP_API_URL=http://localhost:5001/api \
  limpieza-frontend:latest
```

---

## Despliegue en Producción

### Consideraciones para Producción

1. **Base de Datos**: Cambiar de SQLite a PostgreSQL o MySQL
2. **Variables de Entorno**: Usar archivos `.env` o variables de entorno del sistema
3. **HTTPS**: Configurar certificados SSL/TLS
4. **Logging**: Configurar sistema de logs centralizado
5. **Monitoreo**: Implementar herramientas de monitoreo
6. **Backup**: Configurar backups automáticos de la base de datos

### Despliegue en Servidor Linux

#### 1. Preparar el Servidor

```bash
# Actualizar sistema
sudo apt update && sudo apt upgrade -y

# Instalar Docker
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh

# Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
```

#### 2. Clonar y Configurar

```bash
# Clonar repositorio
git clone <url-del-repositorio>
cd arqCS-NCapas

# Crear archivo .env para producción
cat > .env << EOF
FLASK_ENV=production
SQLALCHEMY_DATABASE_URI=postgresql://user:password@db:5432/limpieza_db
REACT_APP_API_URL=https://api.tudominio.com/api
PORT_BACKEND=5001
PORT_FRONTEND=3001
EOF
```

#### 3. Modificar docker-compose.yml para Producción

```yaml
version: '3.8'

services:
  db:
    image: postgres:15
    container_name: limpieza_db
    environment:
      POSTGRES_USER: usuario
      POSTGRES_PASSWORD: contraseña_segura
      POSTGRES_DB: limpieza_db
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - app-network

  backend:
    build:
      context: ./backend
      dockerfile: Dockerfile
    container_name: limpieza_backend
    ports:
      - "5001:5001"
    environment:
      - FLASK_ENV=production
      - SQLALCHEMY_DATABASE_URI=postgresql://usuario:contraseña_segura@db:5432/limpieza_db
      - PORT=5001
    depends_on:
      - db
    networks:
      - app-network
    restart: unless-stopped

  frontend:
    build:
      context: ./frontend
      dockerfile: Dockerfile
    container_name: limpieza_frontend
    ports:
      - "3001:3001"
    environment:
      - REACT_APP_API_URL=https://api.tudominio.com/api
      - PORT=3001
    depends_on:
      - backend
    networks:
      - app-network
    restart: unless-stopped

volumes:
  postgres_data:

networks:
  app-network:
    driver: bridge
```

#### 4. Ejecutar en Producción

```bash
# Construir y ejecutar
docker compose -f docker-compose.yml up -d --build

# Verificar estado
docker compose ps

# Ver logs
docker compose logs -f
```

### Despliegue con Nginx como Reverse Proxy

#### Configuración de Nginx

```nginx
# /etc/nginx/sites-available/limpieza-app

# Frontend
server {
    listen 80;
    server_name tudominio.com;

    location / {
        proxy_pass http://localhost:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}

# Backend API
server {
    listen 80;
    server_name api.tudominio.com;

    location / {
        proxy_pass http://localhost:5001;
        proxy_http_version 1.1;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }
}
```

#### Habilitar Configuración

```bash
sudo ln -s /etc/nginx/sites-available/limpieza-app /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

### Despliegue en Plataformas Cloud

#### Heroku

**Backend:**

```bash
# Instalar Heroku CLI
# Crear Procfile en backend/
echo "web: gunicorn app:app --bind 0.0.0.0:\$PORT" > backend/Procfile

# Login y crear app
heroku login
heroku create limpieza-backend

# Configurar variables de entorno
heroku config:set FLASK_ENV=production
heroku config:set SQLALCHEMY_DATABASE_URI=postgresql://...

# Desplegar
git push heroku main
```

**Frontend:**

```bash
# Crear app de frontend
heroku create limpieza-frontend

# Configurar buildpack
heroku buildpacks:set heroku/nodejs

# Configurar variables
heroku config:set REACT_APP_API_URL=https://limpieza-backend.herokuapp.com/api

# Desplegar
git subtree push --prefix frontend heroku main
```

#### AWS (EC2 + ECS)

1. **Crear imágenes Docker y subirlas a ECR**
2. **Crear task definitions para backend y frontend**
3. **Configurar Application Load Balancer**
4. **Crear servicios ECS**

#### Google Cloud Platform (Cloud Run)

```bash
# Autenticar
gcloud auth login

# Configurar proyecto
gcloud config set project tu-proyecto-id

# Construir y desplegar backend
cd backend
gcloud builds submit --tag gcr.io/tu-proyecto-id/limpieza-backend
gcloud run deploy limpieza-backend \
  --image gcr.io/tu-proyecto-id/limpieza-backend \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated

# Construir y desplegar frontend
cd ../frontend
gcloud builds submit --tag gcr.io/tu-proyecto-id/limpieza-frontend
gcloud run deploy limpieza-frontend \
  --image gcr.io/tu-proyecto-id/limpieza-frontend \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

---

## Despliegue por Tiers Separados

La arquitectura de 3 capas permite desplegar cada tier en servidores físicos diferentes:

### Tier 1: Frontend (Servidor Web)

```bash
# Servidor dedicado para frontend
# Solo necesita servir archivos estáticos o ejecutar React

# Opción 1: Servir build estático con Nginx
cd frontend
npm run build
sudo cp -r build/* /var/www/html/

# Opción 2: Ejecutar con PM2
npm install -g pm2
pm2 start npm --name "frontend" -- start
pm2 save
pm2 startup
```

### Tier 2: Backend (Servidor de Aplicaciones)

```bash
# Servidor dedicado para backend
# Puede escalar horizontalmente con múltiples instancias

# Usar Gunicorn para producción
pip install gunicorn
gunicorn -w 4 -b 0.0.0.0:5001 app:app

# O con systemd service
sudo nano /etc/systemd/system/limpieza-backend.service
```

**Archivo de servicio systemd:**

```ini
[Unit]
Description=Limpieza Backend Service
After=network.target

[Service]
User=www-data
WorkingDirectory=/opt/limpieza/backend
Environment="PATH=/opt/limpieza/backend/venv/bin"
ExecStart=/opt/limpieza/backend/venv/bin/gunicorn -w 4 -b 0.0.0.0:5001 app:app
Restart=always

[Install]
WantedBy=multi-user.target
```

```bash
sudo systemctl enable limpieza-backend
sudo systemctl start limpieza-backend
```

### Tier 3: Base de Datos (Servidor de Base de Datos)

```bash
# Servidor dedicado para PostgreSQL/MySQL

# Instalar PostgreSQL
sudo apt install postgresql postgresql-contrib

# Configurar base de datos
sudo -u postgres psql
CREATE DATABASE limpieza_db;
CREATE USER limpieza_user WITH PASSWORD 'contraseña_segura';
GRANT ALL PRIVILEGES ON DATABASE limpieza_db TO limpieza_user;
\q

# Configurar acceso remoto en /etc/postgresql/15/main/postgresql.conf
# listen_addresses = '*'

# Configurar pg_hba.conf para permitir conexiones
```

---

## Configuración de Variables de Entorno

### Archivo .env para Desarrollo

Crear `backend/.env`:

```env
FLASK_ENV=development
SQLALCHEMY_DATABASE_URI=sqlite:///limpieza_empresas.db
PORT=5001
SECRET_KEY=tu-clave-secreta-aqui
```

### Archivo .env para Producción

```env
FLASK_ENV=production
SQLALCHEMY_DATABASE_URI=postgresql://usuario:contraseña@db-host:5432/limpieza_db
PORT=5001
SECRET_KEY=clave-super-secreta-generada-aleatoriamente
CORS_ORIGINS=https://tudominio.com,https://www.tudominio.com
```

### Usar python-dotenv en Backend

```python
# En backend/app/__init__.py
from dotenv import load_dotenv
import os

load_dotenv()

def create_app():
    app = Flask(__name__)
    app.config['SQLALCHEMY_DATABASE_URI'] = os.getenv(
        'SQLALCHEMY_DATABASE_URI', 
        'sqlite:///limpieza_empresas.db'
    )
    app.config['SECRET_KEY'] = os.getenv('SECRET_KEY', 'dev-secret-key')
    # ...
```

### Variables de Entorno en Frontend

Crear `frontend/.env`:

```env
REACT_APP_API_URL=http://localhost:5001/api
PORT=3001
```

**Nota**: Las variables en React deben comenzar con `REACT_APP_` para ser accesibles.

---

## Solución de Problemas

### Problema: Puerto ya en uso

```bash
# Ver qué proceso usa el puerto
lsof -i :5001
lsof -i :3001

# Matar proceso
kill -9 <PID>

# O cambiar puerto en configuración
PORT=5002 python run.py
```

### Problema: Error de conexión a base de datos

```bash
# Verificar que la base de datos esté corriendo
docker compose ps

# Ver logs de la base de datos
docker compose logs db

# Verificar conexión
psql -h localhost -U usuario -d limpieza_db
```

### Problema: CORS en producción

```python
# En backend/app/__init__.py
CORS(app, resources={
    r"/api/*": {
        "origins": os.getenv('CORS_ORIGINS', 'http://localhost:3001').split(',')
    }
})
```

### Problema: Build de React falla

```bash
# Limpiar cache y reinstalar
cd frontend
rm -rf node_modules package-lock.json
npm cache clean --force
npm install
npm run build
```

### Problema: Contenedores Docker no inician

```bash
# Ver logs detallados
docker compose logs

# Reconstruir sin cache
docker compose build --no-cache

# Limpiar todo y empezar de nuevo
docker compose down -v
docker system prune -a
docker compose up --build
```

---

## Checklist de Despliegue

### Pre-Despliegue

- [ ] Código probado localmente
- [ ] Tests pasando
- [ ] Variables de entorno configuradas
- [ ] Base de datos configurada
- [ ] Secrets y contraseñas seguras
- [ ] Backup de base de datos existente (si aplica)

### Despliegue

- [ ] Servidor preparado (Docker instalado, etc.)
- [ ] Repositorio clonado
- [ ] Variables de entorno configuradas
- [ ] Imágenes Docker construidas
- [ ] Contenedores ejecutándose
- [ ] Servicios accesibles (puertos abiertos)

### Post-Despliegue

- [ ] Verificar que frontend carga correctamente
- [ ] Verificar que API responde
- [ ] Probar operaciones CRUD
- [ ] Verificar logs sin errores
- [ ] Configurar monitoreo
- [ ] Configurar backups automáticos
- [ ] Documentar URLs y credenciales

### Seguridad

- [ ] HTTPS configurado
- [ ] Contraseñas fuertes
- [ ] Firewall configurado
- [ ] CORS configurado correctamente
- [ ] Secrets no en código fuente
- [ ] Logs no contienen información sensible

---

## Comandos Útiles

### Docker

```bash
# Ver contenedores corriendo
docker ps

# Ver todos los contenedores
docker ps -a

# Ver logs de un contenedor
docker logs limpieza-backend
docker logs -f limpieza-backend  # seguir logs

# Ejecutar comando en contenedor
docker exec -it limpieza-backend bash

# Ver uso de recursos
docker stats

# Limpiar recursos no usados
docker system prune
```

### Sistema

```bash
# Ver procesos
ps aux | grep python
ps aux | grep node

# Ver puertos en uso
netstat -tulpn | grep LISTEN
# O en macOS:
lsof -i -P | grep LISTEN

# Ver espacio en disco
df -h

# Ver memoria
free -h
```

---

## Recursos Adicionales

- [Documentación de Docker](https://docs.docker.com/)
- [Documentación de Docker Compose](https://docs.docker.com/compose/)
- [Guía de Despliegue de Flask](https://flask.palletsprojects.com/en/latest/deploying/)
- [Despliegue de React Apps](https://create-react-app.dev/docs/deployment/)
- [Nginx Reverse Proxy](https://nginx.org/en/docs/http/ngx_http_proxy_module.html)

---

## Conclusión

Esta guía cubre los métodos principales de despliegue para la aplicación. Elige el método que mejor se adapte a tus necesidades:

- **Desarrollo local**: Usa `run.sh` o despliegue manual
- **Desarrollo con Docker**: Usa `docker compose`
- **Producción pequeña**: Docker Compose en servidor VPS
- **Producción grande**: Tiers separados con balanceadores de carga
- **Cloud**: Heroku, AWS, GCP según necesidades

Recuerda siempre:
- ✅ Probar localmente antes de desplegar
- ✅ Usar variables de entorno para configuración
- ✅ Configurar backups automáticos
- ✅ Monitorear logs y métricas
- ✅ Mantener seguridad como prioridad

¡Buena suerte con tu despliegue! 🚀


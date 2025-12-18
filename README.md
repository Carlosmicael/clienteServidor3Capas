# Aplicación Web Cliente-Servidor y 3 Capas

Aplicación web que demuestra los estilos arquitectónicos **Cliente-Servidor** y **3 Capas (3-Tier)**, implementando el caso de uso: **"Empresa ofrece servicios de limpieza a empresas"**.

## Arquitectura

La aplicación sigue una arquitectura de 3 capas con patrón MVC:

```
┌─────────────────────────────────────────┐
│  TIER 1: PRESENTACIÓN (Frontend)       │
│  - React + JavaScript                   │
│  - Componentes MVC (Views)              │
└─────────────────┬───────────────────────┘
                  │ HTTP/REST
┌─────────────────▼───────────────────────┐
│  TIER 2: LÓGICA DE NEGOCIO (Backend)   │
│  - Flask API                            │
│  - Controllers (MVC)                    │
│  - Services (Business Logic)            │
└─────────────────┬───────────────────────┘
                  │ SQL
┌─────────────────▼───────────────────────┐
│  TIER 3: ACCESO A DATOS (Database)     │
│  - SQLite Database                      │
│  - Repositories/DAOs                    │
│  - Models                               │
└─────────────────────────────────────────┘
```

## Estructura del Proyecto

```
arqCS-NCapas/
├── frontend/          # Tier 1: Presentación
├── backend/           # Tier 2: Lógica de Negocio
├── database/          # Tier 3: Datos
└── docker-compose.yml # Configuración de despliegue
```

## Entidades del Dominio

1. **Empresa**: Cliente que contrata servicios de limpieza
   - id, nombre, direccion, telefono, email

2. **Servicio**: Tipo de servicio de limpieza ofrecido
   - id, nombre, descripcion, precio_base, duracion_horas

3. **Contrato**: Relación entre Empresa y Servicio
   - id, empresa_id, servicio_id, fecha_inicio, fecha_fin, estado, precio_final

## Requisitos

- Python 3.8+
- Node.js 14+
- Docker y Docker Compose (opcional)

## Instalación y Ejecución

### Opción 1: Con Docker (Recomendado)

```bash
docker-compose up --build
```

### Opción 2: Manual

#### Backend (Tier 2)

```bash
cd backend
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate
pip install -r requirements.txt
python run.py
```

El backend estará disponible en `http://localhost:5000`

#### Frontend (Tier 1)

```bash
cd frontend
npm install
npm start
```

El frontend estará disponible en `http://localhost:3000`

## API Endpoints

### Empresas
- `GET /api/empresas` - Listar todas las empresas
- `GET /api/empresas/<id>` - Obtener empresa por ID
- `POST /api/empresas` - Crear nueva empresa
- `PUT /api/empresas/<id>` - Actualizar empresa
- `DELETE /api/empresas/<id>` - Eliminar empresa

### Servicios
- `GET /api/servicios` - Listar todos los servicios
- `GET /api/servicios/<id>` - Obtener servicio por ID
- `POST /api/servicios` - Crear nuevo servicio
- `PUT /api/servicios/<id>` - Actualizar servicio
- `DELETE /api/servicios/<id>` - Eliminar servicio

### Contratos
- `GET /api/contratos` - Listar todos los contratos
- `GET /api/contratos/<id>` - Obtener contrato por ID
- `POST /api/contratos` - Crear nuevo contrato
- `PUT /api/contratos/<id>` - Actualizar contrato
- `DELETE /api/contratos/<id>` - Eliminar contrato

## CI/CD

El proyecto incluye pipelines de GitHub Actions para automatización:

- **CI/CD Pipeline** (`ci-cd.yml`): Valida código, construye imágenes Docker y ejecuta tests
- **Deploy Pipeline** (`deploy.yml`): Publica imágenes Docker al registro de GitHub Container Registry

Ver [`.github/workflows/README.md`](.github/workflows/README.md) para más detalles.

## Características

- Separación clara de responsabilidades entre tiers
- API RESTful para comunicación cliente-servidor
- Patrón MVC implementado en cada capa
- Cada tier puede desplegarse independientemente
- Pipeline de CI/CD con GitHub Actions


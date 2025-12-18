#!/bin/bash

# Script de ejecución para la aplicación de Servicios de Limpieza
# Arquitectura Cliente-Servidor y 3 Capas

set -e  # Salir si hay errores

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}Uso: ./run.sh [OPCIÓN]${NC}"
    echo ""
    echo "Opciones:"
    echo "  docker          Ejecutar con Docker Compose (recomendado)"
    echo "  backend         Ejecutar solo el backend"
    echo "  frontend        Ejecutar solo el frontend"
    echo "  install         Instalar dependencias (backend y frontend)"
    echo "  init-db         Inicializar base de datos con datos de ejemplo"
    echo "  clean           Limpiar archivos generados (node_modules, venv, etc.)"
    echo "  stop            Detener contenedores Docker"
    echo "  logs            Ver logs de contenedores Docker"
    echo "  help            Mostrar esta ayuda"
    echo ""
    echo "Ejemplos:"
    echo "  ./run.sh docker      # Ejecutar toda la aplicación con Docker"
    echo "  ./run.sh install     # Instalar todas las dependencias"
    echo "  ./run.sh backend     # Ejecutar solo el backend (requiere dependencias instaladas)"
}

# Función para verificar si un comando existe
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Función para verificar requisitos
check_requirements() {
    local missing=0
    
    if ! command_exists python3; then
        echo -e "${RED}✗ Python 3 no está instalado${NC}"
        missing=1
    else
        echo -e "${GREEN}✓ Python 3 encontrado${NC}"
    fi
    
    if ! command_exists node; then
        echo -e "${RED}✗ Node.js no está instalado${NC}"
        missing=1
    else
        echo -e "${GREEN}✓ Node.js encontrado${NC}"
    fi
    
    if ! command_exists npm; then
        echo -e "${RED}✗ npm no está instalado${NC}"
        missing=1
    else
        echo -e "${GREEN}✓ npm encontrado${NC}"
    fi
    
    return $missing
}

# Función para instalar dependencias del backend
install_backend() {
    echo -e "${BLUE}Instalando dependencias del backend...${NC}"
    cd backend
    
    if [ ! -d "venv" ]; then
        echo -e "${YELLOW}Creando entorno virtual...${NC}"
        python3 -m venv venv
    fi
    
    source venv/bin/activate 2>/dev/null || source venv/Scripts/activate 2>/dev/null
    
    echo -e "${YELLOW}Instalando paquetes Python...${NC}"
    pip install --upgrade pip
    pip install -r requirements.txt
    
    cd ..
    echo -e "${GREEN}✓ Dependencias del backend instaladas${NC}"
}

# Función para instalar dependencias del frontend
install_frontend() {
    echo -e "${BLUE}Instalando dependencias del frontend...${NC}"
    cd frontend
    
    if [ ! -d "node_modules" ]; then
        echo -e "${YELLOW}Instalando paquetes npm...${NC}"
        npm install
    else
        echo -e "${YELLOW}Actualizando paquetes npm...${NC}"
        npm install
    fi
    
    cd ..
    echo -e "${GREEN}✓ Dependencias del frontend instaladas${NC}"
}

# Función para instalar todas las dependencias
install_all() {
    echo -e "${BLUE}=== Instalando dependencias ===${NC}"
    check_requirements || {
        echo -e "${RED}Por favor instala los requisitos faltantes${NC}"
        exit 1
    }
    
    install_backend
    install_frontend
    
    echo -e "${GREEN}=== Todas las dependencias instaladas ===${NC}"
}

# Función para verificar Docker Compose
check_docker_compose() {
    # Intentar docker compose (plugin moderno) primero
    if docker compose version >/dev/null 2>&1; then
        echo "docker compose"
        return 0
    # Fallback a docker-compose (legacy)
    elif command_exists docker-compose; then
        echo "docker-compose"
        return 0
    else
        return 1
    fi
}

# Función para ejecutar con Docker
run_docker() {
    echo -e "${BLUE}=== Ejecutando con Docker Compose ===${NC}"
    
    if ! command_exists docker; then
        echo -e "${RED}✗ Docker no está instalado${NC}"
        echo "Por favor instala Docker: https://docs.docker.com/get-docker/"
        exit 1
    fi
    
    DOCKER_COMPOSE_CMD=$(check_docker_compose)
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Docker Compose no está instalado${NC}"
        echo "Por favor instala Docker Compose: https://docs.docker.com/compose/install/"
        exit 1
    fi
    
    echo -e "${GREEN}✓ Docker Compose encontrado (usando: $DOCKER_COMPOSE_CMD)${NC}"
    echo -e "${YELLOW}Construyendo y ejecutando contenedores...${NC}"
    $DOCKER_COMPOSE_CMD up --build -d
    
    echo -e "${GREEN}=== Aplicación ejecutándose en Docker ===${NC}"
    echo -e "${GREEN}Frontend: http://localhost:3001${NC}"
    echo -e "${GREEN}Backend:  http://localhost:5001${NC}"
    echo ""
    echo "Para ver los logs: ./run.sh logs"
    echo "Para detener: ./run.sh stop"
}

# Función para ejecutar backend
run_backend() {
    echo -e "${BLUE}=== Ejecutando Backend ===${NC}"
    cd backend
    
    if [ ! -d "venv" ]; then
        echo -e "${YELLOW}Entorno virtual no encontrado. Instalando dependencias...${NC}"
        install_backend
    fi
    
    source venv/bin/activate 2>/dev/null || source venv/Scripts/activate 2>/dev/null
    
    echo -e "${GREEN}Iniciando servidor Flask en http://localhost:5001${NC}"
    PORT=5001 python3 run.py 2>/dev/null || PORT=5001 python run.py
    
    cd ..
}

# Función para ejecutar frontend
run_frontend() {
    echo -e "${BLUE}=== Ejecutando Frontend ===${NC}"
    cd frontend
    
    if [ ! -d "node_modules" ]; then
        echo -e "${YELLOW}node_modules no encontrado. Instalando dependencias...${NC}"
        install_frontend
    fi
    
    echo -e "${GREEN}Iniciando servidor de desarrollo en http://localhost:3001${NC}"
    PORT=3001 npm start
    
    cd ..
}

# Función para inicializar base de datos
init_database() {
    echo -e "${BLUE}=== Inicializando Base de Datos ===${NC}"
    cd backend
    
    if [ ! -d "venv" ]; then
        echo -e "${YELLOW}Entorno virtual no encontrado. Instalando dependencias...${NC}"
        install_backend
    fi
    
    source venv/bin/activate 2>/dev/null || source venv/Scripts/activate 2>/dev/null
    
    echo -e "${YELLOW}Ejecutando script de inicialización...${NC}"
    cd ../database
    python3 init_db.py 2>/dev/null || python init_db.py
    
    cd ..
    echo -e "${GREEN}✓ Base de datos inicializada${NC}"
}

# Función para limpiar archivos generados
clean() {
    echo -e "${BLUE}=== Limpiando archivos generados ===${NC}"
    
    read -p "¿Estás seguro? Esto eliminará node_modules, venv, y archivos .db (y/n): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "Operación cancelada"
        exit 0
    fi
    
    echo -e "${YELLOW}Eliminando node_modules...${NC}"
    rm -rf frontend/node_modules
    
    echo -e "${YELLOW}Eliminando entorno virtual...${NC}"
    rm -rf backend/venv
    
    echo -e "${YELLOW}Eliminando archivos de base de datos...${NC}"
    rm -f backend/*.db
    rm -f backend/*.sqlite
    rm -f backend/*.sqlite3
    
    echo -e "${YELLOW}Eliminando build de React...${NC}"
    rm -rf frontend/build
    
    echo -e "${YELLOW}Eliminando cache de Python...${NC}"
    find . -type d -name __pycache__ -exec rm -r {} + 2>/dev/null || true
    find . -type f -name "*.pyc" -delete 2>/dev/null || true
    
    echo -e "${GREEN}✓ Limpieza completada${NC}"
}

# Función para detener Docker
stop_docker() {
    echo -e "${BLUE}=== Deteniendo contenedores Docker ===${NC}"
    
    DOCKER_COMPOSE_CMD=$(check_docker_compose)
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Docker Compose no está instalado${NC}"
        exit 1
    fi
    
    $DOCKER_COMPOSE_CMD down
    echo -e "${GREEN}✓ Contenedores detenidos${NC}"
}

# Función para ver logs de Docker
show_logs() {
    echo -e "${BLUE}=== Logs de Docker ===${NC}"
    
    DOCKER_COMPOSE_CMD=$(check_docker_compose)
    if [ $? -ne 0 ]; then
        echo -e "${RED}✗ Docker Compose no está instalado${NC}"
        exit 1
    fi
    
    $DOCKER_COMPOSE_CMD logs -f
}

# Función principal
main() {
    case "${1:-help}" in
        docker)
            run_docker
            ;;
        backend)
            run_backend
            ;;
        frontend)
            run_frontend
            ;;
        install)
            install_all
            ;;
        init-db)
            init_database
            ;;
        clean)
            clean
            ;;
        stop)
            stop_docker
            ;;
        logs)
            show_logs
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            echo -e "${RED}Opción desconocida: $1${NC}"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Ejecutar función principal
main "$@"


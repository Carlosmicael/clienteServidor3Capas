#!/bin/bash

# Script de ejecución Robusto - Servicios de Limpieza
# Soporta Python 3.12 y corrige errores de rutas (cd backend)

set -e  # Salir si hay errores

# 1. DETERMINAR LA RAÍZ DEL PROYECTO (Para que el cd funcione siempre)
# No importa desde dónde llames al script, siempre sabrá dónde están las carpetas.
SCRIPT_PATH="${BASH_SOURCE[0]}"
while [ -L "$SCRIPT_PATH" ]; do
  SCRIPT_DIR="$(cd -P "$(dirname "$SCRIPT_PATH")" && pwd)"
  SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
  [[ $SCRIPT_PATH != /* ]] && SCRIPT_PATH="$SCRIPT_DIR/$SCRIPT_PATH"
done
ROOT_DIR="$(cd -P "$(dirname "$SCRIPT_PATH")" && pwd)"

# Colores para output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Función para mostrar ayuda
show_help() {
    echo -e "${BLUE}Uso: ./run.sh [OPCIÓN]${NC}"
    echo ""
    echo "Opciones:"
    echo "  install         Instala TODO (Backend con Python 3.12 y Frontend)"
    echo "  backend         Ejecuta el Backend (Flask)"
    echo "  frontend        Ejecuta el Frontend (React)"
    echo "  init-db         Inicializa la base de datos"
    echo "  docker          Ejecuta con Docker Compose"
    echo "  clean           Limpia entornos (venv y node_modules)"
    echo "  help            Muestra esta ayuda"
}

# Verificar Python 3.12
check_python() {
    if ! command -v python3.12 >/dev/null 2>&1; then
        echo -e "${RED}✗ Python 3.12 no encontrado.${NC}"
        echo -e "${YELLOW}Por favor instala con: brew install python@3.12${NC}"
        exit 1
    fi
}

# Instalación de Backend
install_backend() {
    echo -e "${BLUE}--- Configurando Backend ---${NC}"
    cd "$ROOT_DIR/backend"
    rm -rf venv
    python3.12 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install -r requirements.txt
    echo -e "${GREEN}✓ Backend configurado.${NC}"
}

# Instalación de Frontend
install_frontend() {
    echo -e "${BLUE}--- Configurando Frontend ---${NC}"
    cd "$ROOT_DIR/frontend"
    npm install
    echo -e "${GREEN}✓ Frontend configurado.${NC}"
}

# EJECUTAR BACKEND
run_backend() {
    check_python
    echo -e "${BLUE}=== Iniciando Backend ===${NC}"
    cd "$ROOT_DIR/backend"
    
    if [ ! -d "venv" ]; then
        echo -e "${YELLOW}Venv no encontrado, instalando primero...${NC}"
        install_backend
    fi
    
    source venv/bin/activate
    echo -e "${GREEN}Servidor Flask en: http://localhost:5001${NC}"
    PORT=5001 python run.py
}

# EJECUTAR FRONTEND
run_frontend() {
    echo -e "${BLUE}=== Iniciando Frontend ===${NC}"
    cd "$ROOT_DIR/frontend"
    
    if [ ! -d "node_modules" ]; then
        echo -e "${YELLOW}Node modules no encontrados, instalando...${NC}"
        install_frontend
    fi
    
    echo -e "${GREEN}Frontend en: http://localhost:3001${NC}"
    PORT=3001 npm start
}

# INICIALIZAR BASE DE DATOS
init_db() {
    echo -e "${BLUE}=== Inicializando Base de Datos ===${NC}"
    cd "$ROOT_DIR/backend"
    source venv/bin/activate
    
    # Intentar encontrar el script de inicialización
    if [ -f "../database/init_db.py" ]; then
        python3.12 ../database/init_db.py
    elif [ -f "init_db.py" ]; then
        python3.12 init_db.py
    else
        echo -e "${RED}✗ No se encontró init_db.py${NC}"
        exit 1
    fi
    echo -e "${GREEN}✓ Base de datos lista.${NC}"
}

# DOCKER
run_docker() {
    echo -e "${BLUE}=== Iniciando con Docker ===${NC}"
    cd "$ROOT_DIR"
    docker compose up --build -d
    echo -e "${GREEN}Contenedores iniciados.${NC}"
}

# CLEAN
clean_all() {
    echo -e "${YELLOW}Limpiando archivos generados...${NC}"
    rm -rf "$ROOT_DIR/backend/venv"
    rm -rf "$ROOT_DIR/frontend/node_modules"
    find "$ROOT_DIR" -type d -name "__pycache__" -exec rm -r {} + 2>/dev/null || true
    echo -e "${GREEN}✓ Limpieza completa.${NC}"
}

# MAIN
case "${1:-help}" in
    install)
        check_python
        install_backend
        install_frontend
        ;;
    backend)
        run_backend
        ;;
    frontend)
        run_frontend
        ;;
    init-db)
        init_db
        ;;
    docker)
        run_docker
        ;;
    clean)
        clean_all
        ;;
    help|--help)
        show_help
        ;;
    *)
        echo -e "${RED}Opción no válida: $1${NC}"
        show_help
        exit 1
        ;;
esac
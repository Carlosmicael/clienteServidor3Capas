"""
Punto de entrada de la aplicación - Tier 2: Lógica de Negocio
"""
import os
from app import create_app

app = create_app()

if __name__ == '__main__':
    # Obtener puerto de variable de entorno o usar 5001 por defecto
    port = int(os.environ.get('PORT', 5001))
    # Obtener modo debug de variable de entorno (False en producción)
    debug = os.environ.get('FLASK_ENV', 'development') == 'development'
    
    app.run(debug=debug, host='0.0.0.0', port=port)



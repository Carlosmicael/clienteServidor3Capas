# Guía del Estudiante - Aplicación Cliente-Servidor y 3 Capas

## 📚 Índice

1. [Introducción](#introducción)
2. [Arquitectura del Proyecto](#arquitectura-del-proyecto)
3. [Cómo Funciona el Proyecto](#cómo-funciona-el-proyecto)
4. [Estructura de Directorios](#estructura-de-directorios)
5. [Flujo de Datos](#flujo-de-datos)
6. [Cómo Agregar un Nuevo Componente](#cómo-agregar-un-nuevo-componente)
7. [Ejemplos Prácticos](#ejemplos-prácticos)
8. [Preguntas Frecuentes](#preguntas-frecuentes)

---

## Introducción

Este proyecto es una aplicación web que demuestra los estilos arquitectónicos **Cliente-Servidor** y **3 Capas (3-Tier)**, implementando el caso de uso: **"Empresa ofrece servicios de limpieza a empresas"**.

### Tecnologías Utilizadas

- **Frontend (Tier 1)**: React + JavaScript
- **Backend (Tier 2)**: Flask (Python) + SQLAlchemy
- **Base de Datos (Tier 3)**: SQLite
- **Patrón de Diseño**: MVC (Model-View-Controller)

---

## Arquitectura del Proyecto

### Arquitectura Cliente-Servidor

```
┌─────────────────┐         HTTP/REST         ┌─────────────────┐
│                 │ ────────────────────────> │                 │
│   CLIENTE       │                           │    SERVIDOR     │
│   (Frontend)    │ <──────────────────────── │    (Backend)    │
│   React         │      Respuestas JSON      │    Flask API    │
└─────────────────┘                           └─────────────────┘
```

### Arquitectura de 3 Capas (3-Tier)

```
┌─────────────────────────────────────────┐
│  TIER 1: PRESENTACIÓN (Frontend)       │
│  - React Components                     │
│  - Views (Vistas MVC)                  │
│  - API Service (Comunicación)          │
└─────────────────┬───────────────────────┘
                  │ HTTP/REST
┌─────────────────▼───────────────────────┐
│  TIER 2: LÓGICA DE NEGOCIO (Backend)   │
│  - Controllers (MVC)                   │
│  - Services (Reglas de Negocio)        │
│  - Validaciones                        │
└─────────────────┬───────────────────────┘
                  │ SQL
┌─────────────────▼───────────────────────┐
│  TIER 3: ACCESO A DATOS (Database)    │
│  - Repositories                        │
│  - Models                              │
│  - SQLite Database                     │
└─────────────────────────────────────────┘
```

---

## Cómo Funciona el Proyecto

### 1. Flujo General de una Petición

Cuando un usuario realiza una acción en el frontend (por ejemplo, crear una empresa):

1. **Usuario interactúa** con la interfaz React (Tier 1)
2. **Frontend envía** una petición HTTP al backend (Tier 2)
3. **Controller recibe** la petición y valida el formato
4. **Service aplica** la lógica de negocio y validaciones
5. **Repository accede** a la base de datos (Tier 3)
6. **Base de datos** ejecuta la operación SQL
7. **Respuesta fluye** de vuelta: Repository → Service → Controller → Frontend
8. **Frontend actualiza** la interfaz con el resultado

### 2. Separación de Responsabilidades

#### Tier 1: Frontend (Presentación)
- **Responsabilidad**: Interfaz de usuario
- **NO hace**: Lógica de negocio, acceso directo a BD
- **Solo hace**: Muestra datos, captura eventos, comunica con API

#### Tier 2: Backend (Lógica de Negocio)
- **Controllers**: Manejan peticiones HTTP, formatean respuestas
- **Services**: Contienen reglas de negocio, validaciones, cálculos
- **NO accede directamente a BD**: Usa Repositories

#### Tier 3: Data Access (Acceso a Datos)
- **Repositories**: Encapsulan operaciones CRUD
- **Models**: Representan entidades de dominio
- **NO contiene lógica de negocio**: Solo acceso a datos

---

## Estructura de Directorios

```
arqCS-NCapas/
├── frontend/                    # Tier 1: Presentación
│   ├── src/
│   │   ├── views/               # Vistas MVC (Componentes React)
│   │   │   ├── EmpresaView.js
│   │   │   ├── ServicioView.js
│   │   │   └── ContratoView.js
│   │   ├── services/            # Cliente API
│   │   │   └── api.js
│   │   └── App.js
│   └── package.json
│
├── backend/                     # Tier 2: Lógica de Negocio
│   ├── app/
│   │   ├── controllers/         # Controladores MVC
│   │   │   ├── empresa_controller.py
│   │   │   ├── servicio_controller.py
│   │   │   └── contrato_controller.py
│   │   ├── services/            # Lógica de Negocio
│   │   │   ├── empresa_service.py
│   │   │   ├── servicio_service.py
│   │   │   └── contrato_service.py
│   │   ├── repositories/        # Tier 3: Acceso a Datos
│   │   │   ├── empresa_repository.py
│   │   │   ├── servicio_repository.py
│   │   │   └── contrato_repository.py
│   │   ├── models/              # Modelos de Dominio
│   │   │   ├── empresa.py
│   │   │   ├── servicio.py
│   │   │   └── contrato.py
│   │   └── config/
│   │       └── database.py
│   └── requirements.txt
│
└── database/                    # Tier 3: Datos
    ├── schema.sql
    └── init_db.py
```

---

## Flujo de Datos

### Ejemplo: Crear una Nueva Empresa

```
1. Usuario llena formulario en EmpresaView.js
   ↓
2. handleSubmit() captura el evento
   ↓
3. empresasAPI.create(data) → api.js
   ↓
4. HTTP POST → http://localhost:5001/api/empresas
   ↓
5. empresa_controller.py → create_empresa()
   ↓
6. EmpresaService.create_empresa() → Validaciones
   ↓
7. EmpresaRepository.create() → Operación SQL
   ↓
8. SQLite ejecuta INSERT INTO empresas...
   ↓
9. Respuesta fluye de vuelta (Repository → Service → Controller)
   ↓
10. Frontend recibe respuesta JSON
   ↓
11. EmpresaView actualiza la lista de empresas
```

---

## Cómo Agregar un Nuevo Componente

Vamos a agregar un nuevo componente llamado **"Empleado"** como ejemplo. Sigue estos pasos en orden:

### Paso 1: Tier 3 - Crear el Modelo (Data Access Layer)

**Archivo**: `backend/app/models/empleado.py`

```python
from app.config.database import db

class Empleado(db.Model):
    """Modelo que representa un empleado"""
    __tablename__ = 'empleados'
    
    id = db.Column(db.Integer, primary_key=True)
    nombre = db.Column(db.String(100), nullable=False)
    apellido = db.Column(db.String(100), nullable=False)
    email = db.Column(db.String(100), nullable=False)
    telefono = db.Column(db.String(20), nullable=False)
    cargo = db.Column(db.String(50), nullable=False)
    
    def to_dict(self):
        """Convierte el modelo a diccionario"""
        return {
            'id': self.id,
            'nombre': self.nombre,
            'apellido': self.apellido,
            'email': self.email,
            'telefono': self.telefono,
            'cargo': self.cargo
        }
    
    def __repr__(self):
        return f'<Empleado {self.nombre} {self.apellido}>'
```

**Actualizar**: `backend/app/models/__init__.py`

```python
from app.models.empleado import Empleado
```

### Paso 2: Tier 3 - Crear el Repositorio (Data Access Layer)

**Archivo**: `backend/app/repositories/empleado_repository.py`

```python
from app.config.database import db
from app.models.empleado import Empleado

class EmpleadoRepository:
    """Repositorio para operaciones CRUD de Empleado"""
    
    @staticmethod
    def get_all():
        """Obtiene todos los empleados"""
        return Empleado.query.all()
    
    @staticmethod
    def get_by_id(empleado_id):
        """Obtiene un empleado por su ID"""
        return Empleado.query.get(empleado_id)
    
    @staticmethod
    def create(empleado_data):
        """Crea un nuevo empleado"""
        empleado = Empleado(
            nombre=empleado_data['nombre'],
            apellido=empleado_data['apellido'],
            email=empleado_data['email'],
            telefono=empleado_data['telefono'],
            cargo=empleado_data['cargo']
        )
        db.session.add(empleado)
        db.session.commit()
        return empleado
    
    @staticmethod
    def update(empleado_id, empleado_data):
        """Actualiza un empleado existente"""
        empleado = EmpleadoRepository.get_by_id(empleado_id)
        if not empleado:
            return None
        
        empleado.nombre = empleado_data.get('nombre', empleado.nombre)
        empleado.apellido = empleado_data.get('apellido', empleado.apellido)
        empleado.email = empleado_data.get('email', empleado.email)
        empleado.telefono = empleado_data.get('telefono', empleado.telefono)
        empleado.cargo = empleado_data.get('cargo', empleado.cargo)
        
        db.session.commit()
        return empleado
    
    @staticmethod
    def delete(empleado_id):
        """Elimina un empleado"""
        empleado = EmpleadoRepository.get_by_id(empleado_id)
        if not empleado:
            return False
        
        db.session.delete(empleado)
        db.session.commit()
        return True
```

### Paso 3: Tier 2 - Crear el Servicio (Business Logic Layer)

**Archivo**: `backend/app/services/empleado_service.py`

```python
from app.repositories.empleado_repository import EmpleadoRepository

class EmpleadoService:
    """Servicio que contiene la lógica de negocio para Empleado"""
    
    @staticmethod
    def get_all_empleados():
        """Obtiene todos los empleados"""
        return EmpleadoRepository.get_all()
    
    @staticmethod
    def get_empleado_by_id(empleado_id):
        """Obtiene un empleado por ID"""
        return EmpleadoRepository.get_by_id(empleado_id)
    
    @staticmethod
    def create_empleado(empleado_data):
        """Crea un nuevo empleado con validaciones"""
        # Validaciones de negocio
        errors = []
        
        if not empleado_data.get('nombre') or len(empleado_data['nombre'].strip()) == 0:
            errors.append('El nombre es requerido')
        
        if not empleado_data.get('apellido') or len(empleado_data['apellido'].strip()) == 0:
            errors.append('El apellido es requerido')
        
        if not empleado_data.get('email') or len(empleado_data['email'].strip()) == 0:
            errors.append('El email es requerido')
        elif '@' not in empleado_data['email']:
            errors.append('El email debe ser válido')
        
        if not empleado_data.get('telefono') or len(empleado_data['telefono'].strip()) == 0:
            errors.append('El teléfono es requerido')
        
        if not empleado_data.get('cargo') or len(empleado_data['cargo'].strip()) == 0:
            errors.append('El cargo es requerido')
        
        if errors:
            raise ValueError('; '.join(errors))
        
        return EmpleadoRepository.create(empleado_data)
    
    @staticmethod
    def update_empleado(empleado_id, empleado_data):
        """Actualiza un empleado con validaciones"""
        empleado = EmpleadoRepository.get_by_id(empleado_id)
        if not empleado:
            raise ValueError('Empleado no encontrado')
        
        # Validaciones de negocio
        if 'email' in empleado_data and empleado_data['email']:
            if '@' not in empleado_data['email']:
                raise ValueError('El email debe ser válido')
        
        return EmpleadoRepository.update(empleado_id, empleado_data)
    
    @staticmethod
    def delete_empleado(empleado_id):
        """Elimina un empleado"""
        empleado = EmpleadoRepository.get_by_id(empleado_id)
        if not empleado:
            raise ValueError('Empleado no encontrado')
        
        return EmpleadoRepository.delete(empleado_id)
```

### Paso 4: Tier 2 - Crear el Controller (MVC)

**Archivo**: `backend/app/controllers/empleado_controller.py`

```python
from flask import Blueprint, request, jsonify
from app.services.empleado_service import EmpleadoService

empleado_bp = Blueprint('empleado', __name__, url_prefix='/api/empleados')

@empleado_bp.route('', methods=['GET'])
def get_all_empleados():
    """Obtiene todos los empleados"""
    try:
        empleados = EmpleadoService.get_all_empleados()
        return jsonify([empleado.to_dict() for empleado in empleados]), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@empleado_bp.route('/<int:empleado_id>', methods=['GET'])
def get_empleado(empleado_id):
    """Obtiene un empleado por ID"""
    try:
        empleado = EmpleadoService.get_empleado_by_id(empleado_id)
        if not empleado:
            return jsonify({'error': 'Empleado no encontrado'}), 404
        return jsonify(empleado.to_dict()), 200
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@empleado_bp.route('', methods=['POST'])
def create_empleado():
    """Crea un nuevo empleado"""
    try:
        data = request.get_json()
        empleado = EmpleadoService.create_empleado(data)
        return jsonify(empleado.to_dict()), 201
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@empleado_bp.route('/<int:empleado_id>', methods=['PUT'])
def update_empleado(empleado_id):
    """Actualiza un empleado"""
    try:
        data = request.get_json()
        empleado = EmpleadoService.update_empleado(empleado_id, data)
        if not empleado:
            return jsonify({'error': 'Empleado no encontrado'}), 404
        return jsonify(empleado.to_dict()), 200
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500

@empleado_bp.route('/<int:empleado_id>', methods=['DELETE'])
def delete_empleado(empleado_id):
    """Elimina un empleado"""
    try:
        result = EmpleadoService.delete_empleado(empleado_id)
        if not result:
            return jsonify({'error': 'Empleado no encontrado'}), 404
        return jsonify({'message': 'Empleado eliminado correctamente'}), 200
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
    except Exception as e:
        return jsonify({'error': str(e)}), 500
```

**Actualizar**: `backend/app/__init__.py`

```python
from app.controllers.empleado_controller import empleado_bp

# Dentro de create_app(), agregar:
app.register_blueprint(empleado_bp)
```

### Paso 5: Tier 1 - Actualizar el Cliente API (Frontend)

**Archivo**: `frontend/src/services/api.js`

```javascript
// Agregar al final del archivo, antes de export default api;

// Empleados API
export const empleadosAPI = {
  getAll: () => api.get('/empleados'),
  getById: (id) => api.get(`/empleados/${id}`),
  create: (data) => api.post('/empleados', data),
  update: (id, data) => api.put(`/empleados/${id}`, data),
  delete: (id) => api.delete(`/empleados/${id}`),
};
```

### Paso 6: Tier 1 - Crear la Vista (Frontend)

**Archivo**: `frontend/src/views/EmpleadoView.js`

```javascript
import React, { useState, useEffect } from 'react';
import { empleadosAPI } from '../services/api';

const EmpleadoView = () => {
  const [empleados, setEmpleados] = useState([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState(null);
  const [success, setSuccess] = useState(null);
  const [editingId, setEditingId] = useState(null);
  const [formData, setFormData] = useState({
    nombre: '',
    apellido: '',
    email: '',
    telefono: '',
    cargo: '',
  });

  useEffect(() => {
    loadEmpleados();
  }, []);

  const loadEmpleados = async () => {
    try {
      setLoading(true);
      const response = await empleadosAPI.getAll();
      setEmpleados(response.data);
      setError(null);
    } catch (err) {
      setError(err.response?.data?.error || 'Error al cargar empleados');
    } finally {
      setLoading(false);
    }
  };

  const handleInputChange = (e) => {
    setFormData({
      ...formData,
      [e.target.name]: e.target.value,
    });
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      setError(null);
      setSuccess(null);
      
      if (editingId) {
        await empleadosAPI.update(editingId, formData);
        setSuccess('Empleado actualizado correctamente');
      } else {
        await empleadosAPI.create(formData);
        setSuccess('Empleado creado correctamente');
      }
      
      resetForm();
      loadEmpleados();
    } catch (err) {
      setError(err.response?.data?.error || 'Error al guardar empleado');
    }
  };

  const handleEdit = (empleado) => {
    setEditingId(empleado.id);
    setFormData({
      nombre: empleado.nombre,
      apellido: empleado.apellido,
      email: empleado.email,
      telefono: empleado.telefono,
      cargo: empleado.cargo,
    });
    window.scrollTo({ top: 0, behavior: 'smooth' });
  };

  const handleDelete = async (id) => {
    if (!window.confirm('¿Está seguro de eliminar este empleado?')) {
      return;
    }
    
    try {
      setError(null);
      await empleadosAPI.delete(id);
      setSuccess('Empleado eliminado correctamente');
      loadEmpleados();
    } catch (err) {
      setError(err.response?.data?.error || 'Error al eliminar empleado');
    }
  };

  const resetForm = () => {
    setEditingId(null);
    setFormData({
      nombre: '',
      apellido: '',
      email: '',
      telefono: '',
      cargo: '',
    });
  };

  if (loading) {
    return <div className="loading">Cargando empleados...</div>;
  }

  return (
    <div className="container">
      <div className="card">
        <h2>{editingId ? 'Editar Empleado' : 'Nuevo Empleado'}</h2>
        
        {error && <div className="error">{error}</div>}
        {success && <div className="success">{success}</div>}
        
        <form onSubmit={handleSubmit}>
          <div className="form-group">
            <label>Nombre:</label>
            <input
              type="text"
              name="nombre"
              value={formData.nombre}
              onChange={handleInputChange}
              required
            />
          </div>
          
          <div className="form-group">
            <label>Apellido:</label>
            <input
              type="text"
              name="apellido"
              value={formData.apellido}
              onChange={handleInputChange}
              required
            />
          </div>
          
          <div className="form-group">
            <label>Email:</label>
            <input
              type="email"
              name="email"
              value={formData.email}
              onChange={handleInputChange}
              required
            />
          </div>
          
          <div className="form-group">
            <label>Teléfono:</label>
            <input
              type="text"
              name="telefono"
              value={formData.telefono}
              onChange={handleInputChange}
              required
            />
          </div>
          
          <div className="form-group">
            <label>Cargo:</label>
            <input
              type="text"
              name="cargo"
              value={formData.cargo}
              onChange={handleInputChange}
              required
            />
          </div>
          
          <div className="button-group">
            <button type="submit" className="btn btn-primary">
              {editingId ? 'Actualizar' : 'Crear'}
            </button>
            {editingId && (
              <button type="button" className="btn btn-secondary" onClick={resetForm}>
                Cancelar
              </button>
            )}
          </div>
        </form>
      </div>

      <div className="card">
        <h2>Lista de Empleados</h2>
        <table>
          <thead>
            <tr>
              <th>ID</th>
              <th>Nombre</th>
              <th>Apellido</th>
              <th>Email</th>
              <th>Teléfono</th>
              <th>Cargo</th>
              <th>Acciones</th>
            </tr>
          </thead>
          <tbody>
            {empleados.length === 0 ? (
              <tr>
                <td colSpan="7" style={{ textAlign: 'center' }}>
                  No hay empleados registrados
                </td>
              </tr>
            ) : (
              empleados.map((empleado) => (
                <tr key={empleado.id}>
                  <td>{empleado.id}</td>
                  <td>{empleado.nombre}</td>
                  <td>{empleado.apellido}</td>
                  <td>{empleado.email}</td>
                  <td>{empleado.telefono}</td>
                  <td>{empleado.cargo}</td>
                  <td>
                    <button
                      className="btn btn-edit"
                      onClick={() => handleEdit(empleado)}
                      style={{ marginRight: '5px' }}
                    >
                      Editar
                    </button>
                    <button
                      className="btn btn-danger"
                      onClick={() => handleDelete(empleado.id)}
                    >
                      Eliminar
                    </button>
                  </td>
                </tr>
              ))
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
};

export default EmpleadoView;
```

### Paso 7: Agregar la Vista al Menú Principal

**Archivo**: `frontend/src/App.js`

```javascript
import EmpleadoView from './views/EmpleadoView';

// En el componente App, agregar un botón en el nav:
<button
  className={currentView === 'empleados' ? 'active' : ''}
  onClick={() => setCurrentView('empleados')}
>
  Empleados
</button>

// Y en renderView():
case 'empleados':
  return <EmpleadoView />;
```

### Paso 8: Actualizar la Base de Datos

La base de datos se creará automáticamente cuando ejecutes la aplicación. SQLAlchemy detectará el nuevo modelo y creará la tabla `empleados`.

---

## Ejemplos Prácticos

### Ejemplo 1: Agregar una Validación de Negocio

En `empleado_service.py`, puedes agregar validaciones personalizadas:

```python
@staticmethod
def create_empleado(empleado_data):
    # Validación personalizada
    if empleado_data.get('cargo') == 'Gerente':
        # Verificar que no haya más de 3 gerentes
        gerentes = EmpleadoRepository.get_all()
        gerentes_count = sum(1 for e in gerentes if e.cargo == 'Gerente')
        if gerentes_count >= 3:
            raise ValueError('No puede haber más de 3 gerentes')
    
    # ... resto del código
```

### Ejemplo 2: Agregar un Campo Calculado

En el modelo `Empleado`, puedes agregar un método que calcule algo:

```python
def get_nombre_completo(self):
    """Retorna el nombre completo del empleado"""
    return f"{self.nombre} {self.apellido}"

def to_dict(self):
    return {
        # ... campos existentes
        'nombre_completo': self.get_nombre_completo()
    }
```

### Ejemplo 3: Agregar Filtros en el Frontend

En `EmpleadoView.js`, puedes agregar un filtro:

```javascript
const [filter, setFilter] = useState('');

// En el render:
<input
  type="text"
  placeholder="Filtrar por nombre..."
  value={filter}
  onChange={(e) => setFilter(e.target.value)}
/>

// Filtrar empleados:
{empleados
  .filter(emp => 
    emp.nombre.toLowerCase().includes(filter.toLowerCase()) ||
    emp.apellido.toLowerCase().includes(filter.toLowerCase())
  )
  .map((empleado) => (
    // ... render del empleado
  ))}
```

---

## Preguntas Frecuentes

### ¿Por qué separar en 3 capas?

- **Mantenibilidad**: Cada capa tiene una responsabilidad clara
- **Escalabilidad**: Puedes escalar cada tier independientemente
- **Testabilidad**: Puedes probar cada capa por separado
- **Reutilización**: La API puede ser usada por diferentes clientes

### ¿Qué va en cada capa?

- **Tier 1 (Frontend)**: Solo presentación, NO lógica de negocio
- **Tier 2 (Backend)**: Toda la lógica de negocio, validaciones, cálculos
- **Tier 3 (Database)**: Solo acceso a datos, NO lógica de negocio

### ¿Cómo pruebo mi nuevo componente?

1. Inicia el backend: `./run.sh backend`
2. Inicia el frontend: `./run.sh frontend`
3. Abre el navegador en `http://localhost:3001`
4. Navega a tu nuevo componente
5. Prueba crear, editar y eliminar registros

### ¿Cómo agrego relaciones entre modelos?

Por ejemplo, relacionar Empleado con Contrato:

```python
# En models/empleado.py
contratos = db.relationship('Contrato', backref='empleado', lazy=True)

# En models/contrato.py
empleado_id = db.Column(db.Integer, db.ForeignKey('empleados.id'), nullable=True)
```

### ¿Cómo despliego la aplicación?

Ver el archivo `README.md` para instrucciones de despliegue con Docker.

---

## Recursos Adicionales

- [Documentación de Flask](https://flask.palletsprojects.com/)
- [Documentación de React](https://react.dev/)
- [Documentación de SQLAlchemy](https://www.sqlalchemy.org/)
- [Arquitectura de 3 Capas](https://en.wikipedia.org/wiki/Multitier_architecture)

---

## Conclusión

Este proyecto demuestra cómo implementar una arquitectura de 3 capas con separación clara de responsabilidades. Al seguir los pasos de esta guía, puedes agregar nuevos componentes manteniendo la arquitectura y el patrón MVC.

**Recuerda**: 
- ✅ Mantén la separación de responsabilidades
- ✅ Sigue el patrón MVC
- ✅ Valida datos en la capa de servicios
- ✅ No accedas directamente a BD desde el frontend
- ✅ Documenta tu código

¡Buena suerte con tu desarrollo! 🚀


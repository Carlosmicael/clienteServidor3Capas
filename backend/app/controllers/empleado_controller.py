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
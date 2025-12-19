from flask import Blueprint, request, jsonify
from app.services.inspeccion_service import InspeccionService

inspeccion_bp = Blueprint('inspeccion', __name__, url_prefix='/api/inspecciones')

@inspeccion_bp.route('', methods=['GET'])
def get_all():
    inspecciones = InspeccionService.listar_inspecciones()
    return jsonify([i.to_dict() for i in inspecciones]), 200

@inspeccion_bp.route('', methods=['POST'])
def create():
    try:
        data = request.get_json()
        nueva = InspeccionService.registrar_inspeccion(data)
        return jsonify(nueva.to_dict()), 201
    except ValueError as e:
        return jsonify({'error': str(e)}), 400
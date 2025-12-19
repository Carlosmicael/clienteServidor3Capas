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
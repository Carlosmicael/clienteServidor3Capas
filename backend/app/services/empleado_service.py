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
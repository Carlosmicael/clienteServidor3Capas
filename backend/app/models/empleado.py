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
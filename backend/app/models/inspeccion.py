from app.config.database import db
from datetime import datetime

class Inspeccion(db.Model):
    """Modelo que representa una inspección de calidad"""
    __tablename__ = 'inspecciones'
    
    id = db.Column(db.Integer, primary_key=True)
    fecha = db.Column(db.DateTime, default=datetime.utcnow)
    empresa_id = db.Column(db.Integer, db.ForeignKey('empresas.id'), nullable=False)
    puntaje = db.Column(db.Integer, nullable=False)  # 1 al 5
    observaciones = db.Column(db.Text)
    inspector = db.Column(db.String(100), nullable=False)
    
    # Relación para obtener el nombre de la empresa fácilmente
    empresa = db.relationship('Empresa', backref='inspecciones')

    def to_dict(self):
        return {
            'id': self.id,
            'fecha': self.fecha.strftime('%Y-%m-%d'),
            'empresa_id': self.empresa_id,
            'empresa_nombre': self.empresa.nombre if self.empresa else "Desconocida",
            'puntaje': self.puntaje,
            'observaciones': self.observaciones,
            'inspector': self.inspector
        }
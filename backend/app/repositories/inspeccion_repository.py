from app.config.database import db
from app.models.inspeccion import Inspeccion

class InspeccionRepository:
    @staticmethod
    def get_all():
        return Inspeccion.query.all()
    
    @staticmethod
    def create(data):
        nueva = Inspeccion(
            empresa_id=data['empresa_id'],
            puntaje=data['puntaje'],
            observaciones=data.get('observaciones', ''),
            inspector=data['inspector']
        )
        db.session.add(nueva)
        db.session.commit()
        return nueva

    @staticmethod
    def delete(id):
        inspeccion = Inspeccion.query.get(id)
        if inspeccion:
            db.session.delete(inspeccion)
            db.session.commit()
            return True
        return False
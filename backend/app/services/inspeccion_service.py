from app.repositories.inspeccion_repository import InspeccionRepository

class InspeccionService:
    @staticmethod
    def listar_inspecciones():
        return InspeccionRepository.get_all()
    
    @staticmethod
    def registrar_inspeccion(data):
        if int(data.get('puntaje', 0)) < 1 or int(data.get('puntaje', 0)) > 5:
            raise ValueError("El puntaje debe estar entre 1 y 5 estrellas")
        
        if not data.get('inspector'):
            raise ValueError("El nombre del inspector es obligatorio")
            
        return InspeccionRepository.create(data)
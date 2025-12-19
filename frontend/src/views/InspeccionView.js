import React, { useState, useEffect } from 'react';
import { inspeccionesAPI, empresasAPI } from '../services/api';

const InspeccionView = () => {
  const [inspecciones, setInspecciones] = useState([]);
  const [empresas, setEmpresas] = useState([]);
  const [loading, setLoading] = useState(false);
  const [formData, setFormData] = useState({ 
    empresa_id: '', 
    puntaje: 5, 
    inspector: '', 
    observaciones: '' 
  });

  useEffect(() => {
    fetchData();
  }, []);

  const fetchData = async () => {
    try {
      setLoading(true);
      const [insRes, empRes] = await Promise.all([inspeccionesAPI.getAll(), empresasAPI.getAll()]);
      setInspecciones(insRes.data);
      setEmpresas(empRes.data);
    } catch (err) {
      console.error("Error cargando datos:", err);
    } finally {
      setLoading(false);
    }
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    try {
      await inspeccionesAPI.create(formData);
      setFormData({ empresa_id: '', puntaje: 5, inspector: '', observaciones: '' });
      fetchData(); // Recargar lista
      alert("✅ Inspección registrada exitosamente");
    } catch (err) { 
      alert("❌ Error: " + (err.response?.data?.error || "No se pudo guardar")); 
    }
  };

  return (
    <div className="container" style={{ padding: '20px' }}>
      <div className="card" style={{ marginBottom: '30px', padding: '25px' }}>
        <h2 style={{ borderBottom: '2px solid #eee', paddingBottom: '10px', marginBottom: '20px' }}>
          📋 Nueva Inspección de Calidad
        </h2>
        
        <form onSubmit={handleSubmit} style={{ display: 'flex', flexDirection: 'column', gap: '15px' }}>
          
          <div style={{ display: 'grid', gridTemplateColumns: '1fr 1fr', gap: '20px' }}>
            <div className="form-group">
              <label style={{ display: 'block', marginBottom: '5px', fontWeight: 'bold' }}>Empresa a Inspeccionar</label>
              <select 
                style={{ width: '100%', padding: '10px', borderRadius: '5px', border: '1px solid #ccc' }}
                value={formData.empresa_id} 
                onChange={e => setFormData({...formData, empresa_id: e.target.value})} 
                required
              >
                <option value="">Seleccione una empresa...</option>
                {empresas.map(e => <option key={e.id} value={e.id}>{e.nombre}</option>)}
              </select>
            </div>

            <div className="form-group">
              <label style={{ display: 'block', marginBottom: '5px', fontWeight: 'bold' }}>Puntaje (1-5 Estrellas)</label>
              <input 
                type="range" 
                min="1" max="5" 
                style={{ width: '100%', cursor: 'pointer' }}
                value={formData.puntaje} 
                onChange={e => setFormData({...formData, puntaje: e.target.value})} 
              />
              <div style={{ textAlign: 'center', fontSize: '20px' }}>
                {"⭐".repeat(formData.puntaje)} <span style={{ fontSize: '14px', color: '#666' }}>({formData.puntaje}/5)</span>
              </div>
            </div>
          </div>

          <div className="form-group">
            <label style={{ display: 'block', marginBottom: '5px', fontWeight: 'bold' }}>Nombre del Inspector</label>
            <input 
              type="text"
              placeholder="Ej. Ing. Carlos Micael" 
              style={{ width: '100%', padding: '10px', borderRadius: '5px', border: '1px solid #ccc' }}
              value={formData.inspector} 
              onChange={e => setFormData({...formData, inspector: e.target.value})} 
              required 
            />
          </div>

          <div className="form-group">
            <label style={{ display: 'block', marginBottom: '5px', fontWeight: 'bold' }}>Observaciones Adicionales</label>
            <textarea 
              placeholder="Detalle el estado del servicio..." 
              style={{ width: '100%', padding: '10px', borderRadius: '5px', border: '1px solid #ccc', minHeight: '80px' }}
              value={formData.observaciones} 
              onChange={e => setFormData({...formData, observaciones: e.target.value})} 
            />
          </div>

          <button type="submit" className="btn btn-primary" style={{ alignSelf: 'flex-start', padding: '10px 25px' }}>
            Guardar Inspección
          </button>
        </form>
      </div>

      <div className="card" style={{ padding: '25px' }}>
        <h3 style={{ marginBottom: '20px' }}>📅 Historial de Inspecciones Realizadas</h3>
        {loading ? <p>Cargando...</p> : (
          <table style={{ width: '100%', borderCollapse: 'collapse' }}>
            <thead style={{ backgroundColor: '#f8f9fa' }}>
              <tr>
                <th style={{ padding: '12px', borderBottom: '2px solid #dee2e6' }}>Fecha</th>
                <th style={{ padding: '12px', borderBottom: '2px solid #dee2e6' }}>Empresa</th>
                <th style={{ padding: '12px', borderBottom: '2px solid #dee2e6' }}>Calificación</th>
                <th style={{ padding: '12px', borderBottom: '2px solid #dee2e6' }}>Inspector</th>
              </tr>
            </thead>
            <tbody>
              {inspecciones.length === 0 ? (
                <tr><td colSpan="4" style={{ textAlign: 'center', padding: '20px' }}>No hay registros disponibles.</td></tr>
              ) : (
                inspecciones.map(i => (
                  <tr key={i.id} style={{ borderBottom: '1px solid #eee' }}>
                    <td style={{ padding: '12px' }}>{i.fecha}</td>
                    <td style={{ padding: '12px', fontWeight: '500' }}>{i.empresa_nombre}</td>
                    <td style={{ padding: '12px' }}>{"⭐".repeat(i.puntaje)}</td>
                    <td style={{ padding: '12px' }}>{i.inspector}</td>
                  </tr>
                ))
              )}
            </tbody>
          </table>
        )}
      </div>
    </div>
  );
};

export default InspeccionView;
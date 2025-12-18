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
  const [filter, setFilter] = useState('');
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
        <input
            type="text"
            placeholder="Filtrar por nombre o apellido..."
            value={filter}
            onChange={(e) => setFilter(e.target.value)}
            style={{ marginBottom: '10px', width: '100%', padding: '5px' }}
        />

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
              empleados
                .filter(emp =>
                    emp.nombre.toLowerCase().includes(filter.toLowerCase()) ||
                    emp.apellido.toLowerCase().includes(filter.toLowerCase())
                )
                .map((empleado) => (

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
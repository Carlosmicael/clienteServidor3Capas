/**
 * Cliente API - Tier 1: Presentación
 * Servicio para comunicación HTTP con el backend (Tier 2)
 */
import axios from 'axios';

const API_BASE_URL = process.env.REACT_APP_API_URL || 'https://905f3940a006.ngrok-free.app/api';
console.log("hola")
console.log(API_BASE_URL)


const api = axios.create({
  baseURL: API_BASE_URL,
  headers: {
    'Content-Type': 'application/json',
    'ngrok-skip-browser-warning': 'true'
  },
});

/**
 si se quiere levantar el fronted desde la misma mauqina usar este codigo de localhost
 const API_BASE_URL = process.env.REACT_APP_API_URL || 'http://localhost:5001/api';

  const api = axios.create({
    baseURL: API_BASE_URL,
    headers: {
      'Content-Type': 'application/json',
    },
  });

 */
// Empresas API
export const empresasAPI = {
  getAll: () => api.get('/empresas'),
  getById: (id) => api.get(`/empresas/${id}`),
  create: (data) => api.post('/empresas', data),
  update: (id, data) => api.put(`/empresas/${id}`, data),
  delete: (id) => api.delete(`/empresas/${id}`),
};

// Servicios API
export const serviciosAPI = {
  getAll: () => api.get('/servicios'),
  getById: (id) => api.get(`/servicios/${id}`),
  create: (data) => api.post('/servicios', data),
  update: (id, data) => api.put(`/servicios/${id}`, data),
  delete: (id) => api.delete(`/servicios/${id}`),
};

// Contratos API
export const contratosAPI = {
  getAll: () => api.get('/contratos'),
  getById: (id) => api.get(`/contratos/${id}`),
  create: (data) => api.post('/contratos', data),
  update: (id, data) => api.put(`/contratos/${id}`, data),
  delete: (id) => api.delete(`/contratos/${id}`),
};

// Empleados API
export const empleadosAPI = {
  getAll: () => api.get('/empleados'),
  getById: (id) => api.get(`/empleados/${id}`),
  create: (data) => api.post('/empleados', data),
  update: (id, data) => api.put(`/empleados/${id}`, data),
  delete: (id) => api.delete(`/empleados/${id}`),
export const inspeccionesAPI = {
  getAll: () => api.get('/inspecciones'),
  create: (data) => api.post('/inspecciones', data),
};

export const inspeccionesAPI = {
  getAll: () => api.get('/inspecciones'),
  create: (data) => api.post('/inspecciones', data),
};

export default api;



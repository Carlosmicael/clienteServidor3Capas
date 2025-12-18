# GitHub Actions Workflows

Este directorio contiene los pipelines de CI/CD para la aplicación.

## Workflows Disponibles

### 1. `ci-cd.yml` - Pipeline de CI/CD Principal

Pipeline completo que se ejecuta en cada push y pull request.

**Jobs incluidos:**

- **Backend Validation**: Valida código Python, ejecuta linting y verifica sintaxis
- **Frontend Validation**: Valida código JavaScript/React y compila el proyecto
- **Docker Build**: Construye las imágenes Docker para backend y frontend
- **Integration Tests**: Ejecuta tests básicos de integración
- **Docker Compose Validation**: Valida la configuración de docker-compose.yml
- **Pipeline Summary**: Genera un resumen del estado del pipeline

**Triggers:**
- Push a branches: `main`, `master`, `develop`
- Pull requests a branches: `main`, `master`, `develop`

### 2. `deploy.yml` - Pipeline de Despliegue

Pipeline para construir y publicar imágenes Docker al registro de GitHub Container Registry.

**Características:**
- Construye y publica imágenes Docker
- Soporta múltiples tags (branch, semver, SHA)
- Solo se ejecuta en push a `main`/`master` o tags versionados

**Triggers:**
- Push a `main` o `master`
- Tags con formato `v*` (ej: `v1.0.0`)
- Ejecución manual (workflow_dispatch)

## Configuración

### Secrets Requeridos

Para el workflow de despliegue, GitHub Actions usa automáticamente `GITHUB_TOKEN` para autenticación. No se requieren secrets adicionales para uso básico.

### Variables de Entorno

Los workflows usan las siguientes variables por defecto:
- `PYTHON_VERSION: '3.11'`
- `NODE_VERSION: '18'`

## Ejecución Local

Para probar los workflows localmente, puedes usar [act](https://github.com/nektos/act):

```bash
# Instalar act
brew install act  # macOS
# o descargar desde https://github.com/nektos/act/releases

# Ejecutar workflow de CI/CD
act push

# Ejecutar workflow de despliegue
act workflow_dispatch
```

## Personalización

### Agregar Tests

Para agregar tests automatizados:

1. **Backend**: Agregar tests en `backend/tests/` y usar `pytest`
2. **Frontend**: Agregar tests en `frontend/src/__tests__/` y usar `jest`

Luego actualizar el workflow para ejecutar los tests:

```yaml
- name: Ejecutar tests
  run: pytest  # o npm test para frontend
```

### Notificaciones

Para agregar notificaciones (Slack, Email, etc.), agrega un step al final del workflow:

```yaml
- name: Notificar resultado
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    text: 'Pipeline completado'
  env:
    SLACK_WEBHOOK_URL: ${{ secrets.SLACK_WEBHOOK }}
```

## Monitoreo

Los resultados de los workflows se pueden ver en:
- Pestaña "Actions" del repositorio en GitHub
- Badge de estado (agregar a README.md):
  ```markdown
  ![CI/CD](https://github.com/USER/REPO/workflows/CI%2FCD%20Pipeline/badge.svg)
  ```


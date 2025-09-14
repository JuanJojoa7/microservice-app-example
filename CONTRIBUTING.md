# Guía de Contribución - Microservice App Example

## 🌿 Estrategia de Branching

### Ramas Principales
- **`master`**: Rama de producción (protegida)
- **`develop`**: Rama de desarrollo principal (protegida)

### Ramas de Trabajo

#### Para Desarrollo
- `feature/nombre-funcionalidad`: Nuevas características
- `bugfix/nombre-del-bug`: Corrección de errores
- `hotfix/nombre-urgente`: Correcciones urgentes en producción

#### Para Operaciones
- `infrastructure/ambiente`: Cambios de infraestructura
- `pipeline/tipo-pipeline`: Cambios en pipelines CI/CD
- `config/nombre-config`: Configuraciones específicas

#### Para Documentación
- `docs/tipo-documentacion`: Documentación y diagramas

## 📝 Convenciones de Commits (Conventional Commits)

### Formato
```
<tipo>[ámbito opcional]: <descripción>

[cuerpo opcional]

[pie opcional]
```

### Tipos de Commits
- **feat**: Nueva funcionalidad
- **fix**: Corrección de errores
- **docs**: Cambios en documentación
- **style**: Cambios de formato (espacios, comas, etc)
- **refactor**: Refactorización de código
- **test**: Agregar o modificar tests
- **chore**: Tareas de mantenimiento
- **ci**: Cambios en CI/CD
- **infra**: Cambios en infraestructura

### Ámbitos (Scopes)
- **auth-api**: Auth API (Go)
- **users-api**: Users API (Java)
- **todos-api**: TODOs API (Node.js)
- **log-processor**: Log Message Processor (Python)
- **frontend**: Frontend (Vue.js)
- **infra**: Infraestructura
- **pipeline**: Pipelines CI/CD
- **docs**: Documentación

### Ejemplos
```bash
feat(auth-api): add JWT token refresh endpoint
fix(todos-api): resolve memory leak in todo deletion
docs(infra): update Docker setup instructions
ci(pipeline): add automated testing for all services
infra(k8s): configure horizontal pod autoscaler
```

## 🔄 Flujo de Trabajo (Workflow)

### Para Desarrolladores
1. Crear rama desde `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b feature/mi-funcionalidad
   ```

2. Hacer commits siguiendo convenciones
3. Push y crear Pull Request a `develop`
4. Code review y merge

### Para Operaciones
1. Crear rama desde `develop`:
   ```bash
   git checkout develop
   git pull origin develop
   git checkout -b infrastructure/mi-cambio
   ```

2. Implementar cambios de infraestructura
3. Testing en ambiente de desarrollo
4. Pull Request con documentación detallada

## 📋 Reglas de Pull Request

### Checklist Obligatorio
- [ ] Commits siguen convenciones
- [ ] Tests pasan (si aplica)
- [ ] Documentación actualizada
- [ ] No hay conflictos con develop
- [ ] Review de al menos 1 persona
- [ ] Build exitoso en CI/CD

### Template de PR
```markdown
## 📝 Descripción
Breve descripción de los cambios

## 🎯 Tipo de Cambio
- [ ] Bug fix
- [ ] Nueva funcionalidad
- [ ] Breaking change
- [ ] Infraestructura
- [ ] Documentación

## 🧪 Testing
Describe las pruebas realizadas

## 📸 Screenshots/Logs
Si aplica, agregar evidencia visual

## ✅ Checklist
- [ ] Mi código sigue las convenciones del proyecto
- [ ] He realizado testing local
- [ ] He actualizado la documentación
- [ ] No hay conflictos con la rama base
```

## 🛡️ Reglas de Protección

### Master Branch
- Require pull request reviews (1 reviewer mínimo)
- Require status checks to pass
- Require up-to-date branches
- No direct pushes

### Develop Branch
- Require pull request reviews (1 reviewer mínimo)
- Require status checks to pass
- Allow force pushes for admins only

## 🏗️ Estructura de Directorios

```
📁 microservice-app-example/
├── 📁 .github/
│   ├── 📁 workflows/          # GitHub Actions
│   └── 📁 ISSUE_TEMPLATE/     # Templates de issues
├── 📁 infrastructure/         # IaC (Terraform, K8s)
├── 📁 scripts/               # Scripts de automatización
├── 📁 docs/                  # Documentación del proyecto
│   ├── architecture/         # Diagramas y arquitectura
│   ├── deployment/           # Guías de despliegue
│   └── development/          # Guías de desarrollo
├── 📁 auth-api/              # Servicio de autenticación
├── 📁 users-api/             # Servicio de usuarios
├── 📁 todos-api/             # Servicio de TODOs
├── 📁 log-message-processor/ # Procesador de logs
├── 📁 frontend/              # Aplicación Vue.js
└── 📄 docker-compose.yml     # Orquestación local
```

## 🤝 División de Responsabilidades

### Compañero A - Infraestructura & Backend
- Branches: `infrastructure/*`, `pipeline/infra-*`
- Servicios: auth-api, users-api, log-processor
- Responsabilidades: Docker, Kubernetes, Terraform, Circuit Breaker

### Compañero B - Desarrollo & Frontend
- Branches: `feature/*`, `pipeline/dev-*`
- Servicios: todos-api, frontend
- Responsabilidades: CI/CD, Testing, Cache Aside, Documentation

### Colaborativo
- Branch: `docs/architecture`
- Responsabilidades: Diagrama de arquitectura, demos, presentación

## 📞 Comunicación

- **Daily sync**: 15 min diarios para coordinar
- **Code review**: Dentro de 24 horas
- **Merge conflicts**: Resolver inmediatamente
- **Blockers**: Comunicar en canal dedicado

## 🚀 Release Process

1. **Feature complete** en develop
2. **Testing** en ambiente de staging
3. **Pull Request** de develop a master
4. **Deployment** automático a producción
5. **Tag** de versión siguiendo semantic versioning
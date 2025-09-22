# Guía de Contribución

## Metodología
Utilizamos Scrum con roles definidos de Dev y Ops para gestionar el flujo de trabajo.

## Estrategia de Branching (GitFlow)

- **master**: Rama de producción. Solo código estable y versionado.
- **develop**: Rama de integración para funcionalidades terminadas.
- **feature/nombre-feature**: Ramas para nuevas funcionalidades (Flujo de Dev).
- **release/v1.X.X**: Ramas para preparar un lanzamiento a producción (Flujo de Ops).
- **hotfix/nombre-fix**: Ramas para correcciones urgentes en producción (Flujo de Ops).

## Convención de Commits
Usaremos "Conventional Commits". Cada commit debe tener el formato:
`<tipo>(<ámbito>): <descripción>`

- **Tipos**: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`, `ci`, `infra`.
- **Ámbitos**: `auth-api`, `users-api`, `todos-api`, `log-processor`, `frontend`.

**Ejemplo**: `feat(todos-api): Add caching for todo list`
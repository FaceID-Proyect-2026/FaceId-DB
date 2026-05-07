# FaceLit DB

Repositorio dedicado a la gestión y versionado de la base de datos del sistema **FaceLit** — sistema automatizado de control de asistencia mediante reconocimiento facial para el SENA.

## Propósito del Sistema

FaceLit reemplaza el registro manual de asistencia (listas en Excel) por un proceso automático basado en reconocimiento facial. El sistema identifica a cada aprendiz al ingresar al ambiente de formación, registra la hora exacta y clasifica su estado como **puntual**, **tardío** o **ausente**. Genera reportes organizados para instructores y administradores.

Este repositorio gestiona únicamente la base de datos: estructura, lógica, permisos y datos de referencia.

---

## Alcance Actual

Este repositorio administra lo que existe en la rama activa:

- Extensión `uuid-ossp`
- Schemas: `security`, `academic`, `attendance`, `facial`, `audit`
- Tablas base por módulo funcional

No incluye aún: vistas, funciones, procedimientos, triggers, índices ni datos semilla.

---

## Módulos del Sistema (Requerimientos Funcionales)

La base de datos está organizada alrededor de los siguientes módulos:

| Módulo | Descripción |
|--------|-------------|
| **RF-1 Accesos** | Autenticación, roles, permisos y restablecimiento de contraseña |
| **RF-2 Ambientes** | Registro, consulta y restricciones de ambientes de formación |
| **RF-3 Gestión Académica** | Programas, fichas y aprendices |
| **RF-4 Horarios** | Horarios por ficha, ambiente e instructor |
| **RF-5 Reconocimiento Facial** | Registro de rostros y vectores biométricos (desde Raspberry Pi) |
| **RF-6 Asistencias** | Entradas, salidas, validación de ambiente y cálculo de retrasos |
| **RF-7 Reportes** | Asistencia individual, grupal, estadísticas y exportación |
| **RF-8 Notificaciones** | Generación automática y envío por correo |
| **RF-9 Perfil** | Configuración de usuario y personalización |
| **RF-10 Administración** | Gestión avanzada de usuarios y roles |
| **RF-11 Bitácoras** | Auditoría de acciones internas y externas |

---

## Estructura del Repositorio

```text
facelit-db/
├── changelog-master.yaml
├── 01_ddl/
│   ├── changelog.yaml
│   ├── 00_extensions/
│   │   └── changelog.yaml
│   ├── 01_schemas/
│   │   └── changelog.yaml
│   ├── 02_types/
│   │   └── changelog.yaml
│   ├── 03_tables/
│   │   └── changelog.yaml
│   ├── 04_views/
│   │   └── changelog.yaml
│   ├── 05_materialized_views/
│   │   └── changelog.yaml
│   ├── 06_functions/
│   │   └── changelog.yaml
│   ├── 07_procedures/
│   │   └── changelog.yaml
│   ├── 08_triggers/
│   │   └── changelog.yaml
│   └── 09_indexes/
│       └── changelog.yaml
├── 02_dml/
│   ├── changelog.yaml
│   ├── 00_inserts/
│   │   └── changelog.yaml
│   ├── 01_updates/
│   │   └── changelog.yaml
│   ├── 02_deletes/
│   │   └── changelog.yaml
│   ├── 03_upserts/
│   │   └── changelog.yaml
│   └── 04_patches/
│       └── changelog.yaml
├── 03_dcl/
│   ├── changelog.yaml
│   ├── 00_roles/
│   │   └── changelog.yaml
│   ├── 01_grants/
│   │   └── changelog.yaml
│   └── 02_policies/
│       └── changelog.yaml
├── 04_tcl/
│   ├── changelog.yaml
│   ├── 00_transaction_blocks/
│   │   └── changelog.yaml
│   └── 01_manual_recoveries/
│       └── changelog.yaml
├── 05_rollbacks/
│   ├── 01_ddl/
│   │   ├── 00_extensions/
│   │   ├── 01_schemas/
│   │   ├── 02_types/
│   │   ├── 03_tables/
│   │   ├── 04_views/
│   │   ├── 05_materialized_views/
│   │   ├── 06_functions/
│   │   ├── 07_procedures/
│   │   ├── 08_triggers/
│   │   └── 09_indexes/
│   ├── 02_dml/
│   │   ├── 00_inserts/
│   │   ├── 01_updates/
│   │   ├── 02_deletes/
│   │   ├── 03_upserts/
│   │   └── 04_patches/
│   └── 03_dcl/
│       ├── 00_roles/
│       ├── 01_grants/
│       └── 02_policies/
├── docker-compose.yml
├── .env.example
├── liquibase.properties.example
├── docs/
└── docker/
    └── liquibase/
        └── Dockerfile
```

---

## Arquitectura de Schemas

La base de datos se divide en schemas por responsabilidad funcional:

| Schema | Responsabilidad |
|--------|----------------|
| `security` | Usuarios, roles, permisos, sesiones (RF-1, RF-10) |
| `academic` | Programas, fichas, aprendices, ambientes, horarios (RF-2, RF-3, RF-4) |
| `facial` | Vectores biométricos, modelos de reconocimiento (RF-5) |
| `attendance` | Registros de asistencia, validaciones, excusas (RF-6, RF-7) |
| `audit` | Bitácoras, notificaciones, historial de acciones (RF-8, RF-11) |

---

## Arquitectura de Capas SQL

| Capa | Directorio | Responsabilidad |
|------|------------|----------------|
| DDL | `01_ddl/` | Estructura: extensiones, schemas, tipos, tablas, vistas, funciones, triggers, índices |
| DML | `02_dml/` | Datos: inserts, updates, deletes, upserts, parches |
| DCL | `03_dcl/` | Seguridad: roles, grants, políticas de acceso |
| TCL | `04_tcl/` | Transacciones excepcionales y recuperaciones manuales |
| Rollbacks | `05_rollbacks/` | Árbol espejo con scripts de reversa por capa |

---

## Estado Actual del Despliegue

### Capas activas hoy

- `01_ddl/00_extensions` — habilita `uuid-ossp`
- `01_ddl/01_schemas` — crea los cinco schemas del sistema
- `01_ddl/03_tables` — tablas base de todos los módulos

### Capas reservadas (listas, sin uso activo aún)

- `01_ddl/02_types` — tipos enumerados (estado de asistencia, roles, etc.)
- `01_ddl/04_views` — vistas para reportes frecuentes
- `01_ddl/05_materialized_views` — vistas materializadas para estadísticas históricas
- `01_ddl/06_functions` — lógica de cálculo de retrasos, validaciones
- `01_ddl/07_procedures` — registro de asistencia, generación de reportes
- `01_ddl/08_triggers` — auditoría automática, updated_at
- `01_ddl/09_indexes` — optimización de búsquedas por aprendiz, fecha, ambiente
- `02_dml/` — datos semilla de roles, programas y configuración base
- `03_dcl/` — roles de BD y grants por schema
- `04_tcl/` — bloques transaccionales excepcionales

Una carpeta existe y tiene propósito definido, pero no participa en el despliegue hasta que se activa desde su `changelog.yaml` padre.

---

## Estado Esperado Después del Despliegue Inicial

Cuando el flujo funciona correctamente, la base queda con:

- Extensión `uuid-ossp` habilitada
- Schemas: `security`, `academic`, `facial`, `attendance`, `audit`
- Tablas del módulo `security`: `role`, `user`, `permission`, `user_session`, `password_reset`
- Tablas del módulo `academic`: `program`, `cohort`, `learner`, `environment`, `environment_restriction`, `schedule`, `instructor_schedule`
- Tablas del módulo `facial`: `face_encoding`, `recognition_model`, `recognition_event`
- Tablas del módulo `attendance`: `attendance_record`, `attendance_excuse`, `attendance_validation`
- Tablas del módulo `audit`: `system_log`, `notification`, `notification_log`

---

## Requisitos

- Docker Desktop
- Docker Compose
- Liquibase local solo si se ejecuta fuera de Docker

---

## Uso Rápido con Docker

### 1. Configurar variables de entorno (opcional)

```bash
cp .env.example .env
# Editar .env si se necesitan credenciales o puertos distintos a los valores por defecto
```

### 2. Levantar PostgreSQL

```bash
docker compose -p facelit-db up -d postgres
```

### 3. Construir imagen de Liquibase (solo la primera vez)

```bash
docker compose -p facelit-db --profile tooling build liquibase
```

### 4. Validar el changelog

```bash
docker compose -p facelit-db --profile tooling run --rm liquibase validate
```

### 5. Ver el estado actual

```bash
docker compose -p facelit-db --profile tooling run --rm liquibase status
```

### 6. Aplicar la estructura base

```bash
docker compose -p facelit-db --profile tooling run --rm liquibase update
```

### 7. Generar SQL sin ejecutar (recomendado antes de aplicar en producción)

```bash
docker compose -p facelit-db --profile tooling run --rm liquibase update-sql
```

---

## Reset Limpio del Proyecto

Ejecutar desde la raíz cuando se necesite volver a aplicar todo desde cero:

```bash
docker compose -p facelit-db down --volumes --remove-orphans
docker compose -p facelit-db up -d postgres
docker compose -p facelit-db --profile tooling run --rm liquibase validate
docker compose -p facelit-db --profile tooling run --rm liquibase update
```

> En DBeaver puede aparecer `SQL Error [08003]: This connection has been closed` después del reset. Solo reconectar el datasource y refrescar `Schemas`.

---

## Rollback Operativo

Cada `changeSet` activo de DDL tiene su `rollback.sqlFile` en `05_rollbacks/`.

```bash
# Rollback del último changeSet aplicado
docker compose -p facelit-db --profile tooling run --rm liquibase rollback-count --count=1

# Rollback de los últimos N changesets
docker compose -p facelit-db --profile tooling run --rm liquibase rollback-count --count=3

# Preview sin ejecutar (recomendado siempre antes de revertir)
docker compose -p facelit-db --profile tooling run --rm liquibase rollback-count-sql --count=1
```

### Flujo profesional con tag

```bash
# 1. Marcar punto estable antes del cambio
docker compose -p facelit-db --profile tooling run --rm liquibase tag --tag=facelit_stable_v1

# 2. Aplicar nuevos cambios
docker compose -p facelit-db --profile tooling run --rm liquibase update

# 3. Volver al punto estable si algo falla
docker compose -p facelit-db --profile tooling run --rm liquibase rollback --tag=facelit_stable_v1
```

### Rollback por fecha

```bash
docker compose -p facelit-db --profile tooling run --rm liquibase rollback-to-date "2026-05-01 09:00:00"
```

### Auditoría post-despliegue

```bash
docker compose -p facelit-db --profile tooling run --rm liquibase history
```

### Verificación directa en base de datos

```sql
SELECT orderexecuted, id, author, filename, tag
FROM public.databasechangelog
ORDER BY orderexecuted;
```

---

## Uso con Liquibase Local

Usar solo si la instalación local tiene el driver JDBC de PostgreSQL disponible.

```bash
cp liquibase.properties.example liquibase.properties
# Ajustar credenciales si se cambiaron los valores por defecto

liquibase validate
liquibase status
liquibase update
liquibase rollback-count --count=1
```

---

## Orden de Ejecución del Master Changelog

El `changelog-master.yaml` aplica los cambios en este orden:

1. Habilita la extensión `uuid-ossp`
2. Crea los cinco schemas del sistema
3. Crea tablas del schema `security`
4. Crea tablas del schema `academic`
5. Crea tablas del schema `facial`
6. Crea tablas del schema `attendance`
7. Crea tablas del schema `audit`

Este orden evita errores por dependencias entre tablas y llaves foráneas.

---

## Reglas para Cambios Nuevos

- No modificar changesets ya aplicados
- Crear nuevos archivos para cada cambio posterior
- Mantener el orden de dependencias en el master changelog
- No subir secretos reales al repositorio
- Validar con `validate` y `update-sql` antes de aplicar en un entorno compartido
- Antes de un `UPDATE` o `DELETE` sensible, definir por escrito la estrategia de reversa
- Antes de un parche delicado, crear un `tag`

---

## Política de IDs de Changeset

Se usan IDs semánticos, no UUIDs aleatorios. Liquibase garantiza unicidad por la combinación `id + author + logicalFilePath`.

Formato recomendado: `{NNN}-{modulo}-{descripcion-corta}`

Ejemplos:
- `001-security-create-role-table`
- `002-academic-create-program-table`
- `003-facial-create-face-encoding-table`

---

## Buenas Prácticas Adoptadas

- Un solo `master changelog` en la raíz
- Separación por capa SQL y por responsabilidad de schema
- Archivos pequeños y ordenados por responsabilidad
- Un `changelog.yaml` por paquete y subpaquete
- Changesets declarativos en YAML con `sqlFile` de avance y reversa
- Rollback separado en `sqlFile` dedicados bajo `05_rollbacks/`
- Configuración local separada en archivos `.example`
- Runner Docker de Liquibase con driver PostgreSQL preinstalado
- Puerto `5433` por defecto para evitar choques con una instalación local de PostgreSQL en `5432`
- Contrato de despliegue visible desde la raíz del repositorio

---

## Integrantes del Proyecto

| Rol | Responsabilidad principal |
|-----|--------------------------|
| Base de datos (1) | Modelo entidad-relación, tablas, vistas, lógica SQL |
| Base de datos (2) | Estructura del repositorio, Liquibase, Docker, índices, triggers |
| Frontend | Wireframes, diseño visual, maquetado de interfaces |

---

## Sobre FaceLit

**FaceLit** es un sistema desarrollado para el SENA que automatiza el control de asistencia en ambientes de formación mediante reconocimiento facial. Identifica aprendices en tiempo real, registra entradas con precisión horaria y genera reportes que apoyan la gestión académica de instructores y administradores.
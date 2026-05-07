# Roadmap - Hoja de Ruta del Proyecto

## Visión General

FaceLit DB evoluciona en 5 fases desde estructura mínima hasta sistema completo de auditoría y reportes.

---

## Timeline Estimado

```
FASE 1: Estructura Base (ACTUAL)        | Semana 1-2
├─ Schemas y extensiones                ✅ COMPLETADO
├─ Tablas core (user, credential)       ✅ COMPLETADO
└─ Rollbacks básicos                     ✅ COMPLETADO

FASE 2: Núcleo Académico               | Semana 3-4
├─ Tablas: program, course, learner     ⏳ INICIO PRÓXIMO
├─ Relaciones y constraints             ⏳ PENDIENTE
└─ Índices iniciales                    ⏳ PENDIENTE

FASE 3: Asistencias y Biometría       | Semana 5-6
├─ Tablas: attendance, environment      ⏳ PENDIENTE
├─ Tablas: facial_vector, capture       ⏳ PENDIENTE
└─ Funciones de validación              ⏳ PENDIENTE

FASE 4: Seguridad y Auditoría         | Semana 7-8
├─ Roles y grants (DCL)                 ⏳ PENDIENTE
├─ Auditoría automática (triggers)      ⏳ PENDIENTE
└─ Políticas de acceso (RLS)            ⏳ PENDIENTE

FASE 5: Reportes y Optimización       | Semana 9+
├─ Vistas materializadas                ⏳ PENDIENTE
├─ Procedimientos almacenados           ⏳ PENDIENTE
└─ Índices de rendimiento               ⏳ PENDIENTE
```

---

## FASE 1: Estructura Base (ACTUAL) ✅

### Estado: 90% Completado

**Completados**:
- ✅ Extensión `uuid-ossp` habilitada
- ✅ 5 Schemas creados (security, academic, attendance, facial, audit)
- ✅ Tabla `user` implementada
- ✅ Tabla `credential` implementada
- ✅ Rollbacks para extensión y schemas

**En Revisión**:
- 🔄 Corrección de inconsistencias en `credential` (FK, tipos de dato)
- 🔄 Mejoras de campos (timestamps, soft deletes)

**Deliverables**:
- 📦 changesets de Liquibase funcionales
- 📦 docker-compose con PostgreSQL 16
- 📦 documentación de arquitectura

**Criterio de Salida**: 
- Todas las inconsistencias corregidas
- Ambas tablas con datos de prueba
- Rollbacks verificados

---

## FASE 2: Núcleo Académico | ETA: Semana 3-4

### Objetivo

Establecer la estructura académica que permite organizar a los aprendices.

### Nuevas Tablas

#### `academic.program`
Representa programas de formación SENA (ej: "Tecnólogo en Sistemas").

```
Columnas:
- id (UUID PK)
- code (VARCHAR 20, UNIQUE) - Código oficial SENA
- name (VARCHAR 100)
- duration_hours (INTEGER)
- status (ACTIVE|INACTIVE)
- created_at, updated_at

Índices:
- code, status
```

#### `academic.course`
Fichas o cohortes dentro de programas.

```
Columnas:
- id (UUID PK)
- id_program (FK → program.id)
- code (VARCHAR 30, UNIQUE) - Código ficha (ej: "2401-T-001")
- start_date (DATE)
- end_date (DATE)
- instructor_assigned (UUID FK → user.id)
- max_learners (INTEGER)
- status (PLANNING|ACTIVE|FINISHED|CANCELLED)
- created_at, updated_at

Índices:
- id_program, code, status, start_date
```

#### `academic.learner`
Aprendices registrados en fichas.

```
Columnas:
- id (UUID PK, mismo que user.id)
- id_course (FK → course.id)
- id_user (FK → user.id)
- enrollment_date (DATE)
- curriculum_status (NOT_STARTED|IN_PROGRESS|COMPLETED|DROPPED)
- created_at, updated_at

Índices:
- id_course, id_user, enrollment_date
```

#### `academic.instructor`
Instructores asignados a cursos.

```
Columnas:
- id (UUID PK, mismo que user.id)
- id_user (FK → user.id)
- specialization (VARCHAR 100)
- assigned_courses (INTEGER, calculado)
- status (ACTIVE|INACTIVE)
- created_at, updated_at

Índices:
- id_user, status
```

### Relaciones

```
program (1)
    ↓
    └─→ (N) course
            ├─→ (1) instructor
            └─→ (N) learner
                    └─→ (1) user
```

### Reglas de Integridad

1. Un programa tiene múltiples fichas
2. Una ficha pertenece a un programa
3. Una ficha tiene un instructor asignado
4. Un aprendiz pertenece a una ficha
5. Las fechas de ficha no pueden solaparse injustificadamente
6. Máximo N aprendices por ficha

### Queries Clave

```sql
-- Aprendices de una ficha
SELECT u.first_name, u.last_name, l.enrollment_date
FROM learner l
JOIN "user" u ON u.id = l.id_user
WHERE l.id_course = ?;

-- Fichas activas de un programa
SELECT * FROM course 
WHERE id_program = ? 
  AND status = 'ACTIVE'
  AND start_date <= NOW() 
  AND end_date >= NOW();
```

### Criteria de Completitud

- ✅ 4 nuevas tablas con constraints completos
- ✅ Relaciones FK verificadas
- ✅ 5 índices mínimos por optimización
- ✅ Script de DML con datos de prueba
- ✅ Rollbacks para todas las tablas

---

## FASE 3: Asistencias y Biometría | ETA: Semana 5-6

### Objetivo

Implementar registro de asistencias mediante reconocimiento facial.

### Nuevas Tablas

#### `attendance.environment`
Ambientes donde se registra asistencia.

```
environment:
- id (UUID PK)
- code (VARCHAR 20, UNIQUE) - Código ambiente (ej: "AULA-101")
- name (VARCHAR 100)
- location (VARCHAR 100)
- capacity (INTEGER)
- is_active (BOOLEAN)
- created_at, updated_at
```

#### `attendance.attendance_record`
Registro de cada entrada/salida.

```
attendance_record:
- id (UUID PK)
- id_learner (FK → learner.id)
- id_environment (FK → environment.id)
- check_in_time (TIMESTAMPZ)
- check_out_time (TIMESTAMPZ, nullable)
- status (ON_TIME|LATE|ABSENCE|EARLY_DEPARTURE)
- facial_match_score (NUMERIC 0-100)
- confidence (NUMERIC 0-100)
- created_at, updated_at
```

#### `facial.facial_vector`
Embeddings biométricos de cada aprendiz.

```
facial_vector:
- id (UUID PK)
- id_learner (FK → learner.id)
- vector_data (bytea) - Embedding de 128-512 dimensiones
- capture_date (TIMESTAMPZ)
- quality_score (NUMERIC 0-100)
- is_primary (BOOLEAN)
- created_at, updated_at
```

#### `facial.facial_capture`
Capturas de rostro para auditoría.

```
facial_capture:
- id (UUID PK)
- id_learner (FK → learner.id)
- image_path (VARCHAR 255) - Ruta en S3/almacenamiento
- capture_timestamp (TIMESTAMPZ)
- device_id (VARCHAR 50) - Raspberry Pi que capturó
- status (PROCESSED|PENDING|FAILED)
- created_at, updated_at
```

### Lógica de Negocio

1. **Entrada Normal**:
   - Aprendiz llega → Captura facial por Raspberry Pi
   - Sistema busca coincidencia en `facial_vector`
   - Si confidence > 95% → Registra en `attendance_record` con status
   - Status = ON_TIME si está dentro del horario permitido

2. **Salida**:
   - Aprendiz se retira → Actualiza `check_out_time`
   - Calcula duración de permanencia
   - Almacena en auditoría

3. **Rechazos**:
   - Si confidence < 95% → Reintenta o requiere validación manual
   - Aprendiz puede escanear cédula como fallback

### Criteria de Completitud

- ✅ 4 nuevas tablas
- ✅ Funciones de validación de horarios
- ✅ Triggers para auditoría de cambios
- ✅ Índices para queries de asistencia
- ✅ Stored procedures para reportes básicos

---

## FASE 4: Seguridad y Auditoría | ETA: Semana 7-8

### Objetivo

Implementar control de acceso y auditoría completa.

### DCL: Roles y Grants

```sql
-- Roles a crear
ROLE app_admin
ROLE app_instructor
ROLE app_learner
ROLE app_auditor
ROLE app_system
```

### Auditoría Automática

Tabla `audit.audit_log`:
```
audit_log:
- id (UUID PK)
- table_name (VARCHAR 50)
- operation (INSERT|UPDATE|DELETE)
- record_id (UUID)
- old_values (JSONB)
- new_values (JSONB)
- changed_by (UUID FK → user.id)
- changed_at (TIMESTAMPZ)
- ip_address (INET)
```

### Triggers de Auditoría

Crear trigger para cada tabla crítica:
- `user` → Auditar cambios de estado
- `credential` → Auditar intentos fallidos
- `attendance_record` → Auditar registros
- `facial_capture` → Auditar capturas

### Row-Level Security (RLS)

```sql
-- Learner solo ve sus propios registros
ALTER TABLE attendance_record ENABLE ROW LEVEL SECURITY;

CREATE POLICY learner_view_own_records ON attendance_record
  FOR SELECT USING (id_learner = current_user_id());
```

---

## FASE 5: Reportes y Optimización | ETA: Semana 9+

### Vistas Materializadas

```
mv_attendance_summary
├─ Asistencia por aprendiz por mes
├─ Tasa de puntualidad
└─ Faltas acumuladas

mv_facial_recognition_stats
├─ Tasa de reconocimiento exitoso
├─ Promedio de confianza
└─ Fallos por dispositivo

mv_instructor_class_summary
├─ Aprendices por clase
├─ Asistencias registradas
└─ Reportes generados
```

### Procedimientos Almacenados

```sql
-- Generar reporte de asistencia
get_attendance_report(
  p_learner_id UUID,
  p_start_date DATE,
  p_end_date DATE
)

-- Generar reporte para instructor
get_class_attendance_report(
  p_course_id UUID,
  p_month INTEGER
)

-- Estadísticas de reconocimiento facial
get_facial_recognition_stats(
  p_month INTEGER
)
```

### Optimización

- Índices adicionales por consultas frecuentes
- Particionamiento de `attendance_record` por mes/año
- Vacío automático de datos antiguos

---

## Dependencias Entre Fases

```
FASE 1 (Base)
    ↓
    ├─→ FASE 2 (Académico) - Requerido para FASE 3
    │   └─→ FASE 3 (Asistencias) - Requerido para FASE 4
    │       └─→ FASE 4 (Auditoría)
    │           └─→ FASE 5 (Reportes)
    │
    └─→ FASE 4 (Auditoría) - Puede iniciarse en paralelo con FASE 2
        └─→ FASE 5 (Reportes)
```

**Nota**: La auditoría puede implementarse después de la FASE 3 o en paralelo.

---

## Criterios de Éxito por Fase

### FASE 1
- [ ] Todas las tablas con datos de prueba funcionales
- [ ] Rollbacks verificados manualmente
- [ ] Documentación completa

### FASE 2
- [ ] Relaciones FK funcionando sin errores
- [ ] Queries de ejemplo ejecutadas exitosamente
- [ ] Índices mejoran rendimiento de búsquedas

### FASE 3
- [ ] Registro de asistencias sin errores
- [ ] Triggers de auditoría funcionando
- [ ] Funciones de validación testeadas

### FASE 4
- [ ] Roles asignados y probados
- [ ] Auditoría completa funcionando
- [ ] Políticas RLS verificadas

### FASE 5
- [ ] Vistas materializadas generan reportes
- [ ] Procedimientos devuelven datos correctos
- [ ] Performance aceptable (< 2s para reportes)

---

## Riesgos y Mitigaciones

| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|-------------|---------|-----------|
| Cambios en requisitos académicos | Media | Alto | Reviews mensuales con SENA |
| Performance con muchos registros | Baja | Alto | Indexación progresiva |
| Privacidad de datos biométricos | Media | Crítico | Encriptación + RLS + auditoría |
| Inconsistencias en datos | Media | Medio | Constraints + triggers |
| Cambios en estructura SENA | Baja | Alto | Versionado de schema |

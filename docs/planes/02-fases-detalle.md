# Fases de Desarrollo - Detalle Técnico

## FASE 1: Estructura Base - Detalle Actual

### Sprint 1.1: Infraestructura (Completado)

**Tareas Completadas**:

1. **PostgreSQL + Docker**
   - ✅ Setup docker-compose con PostgreSQL 16 Alpine
   - ✅ Volúmenes persistentes configurados
   - ✅ Health checks implementados
   - ✅ Variables de entorno centralizadas

2. **Extensiones**
   - ✅ Habilitado `uuid-ossp` en schema `public`
   - ✅ Rollback creado
   - ✅ Changelog: `01_ddl/00_extensions/001_enable_uuid_extension.sql`

3. **Schemas**
   - ✅ `security` - Autenticación y accesos
   - ✅ `academic` - Estructura educativa
   - ✅ `attendance` - Asistencias
   - ✅ `facial` - Biometría
   - ✅ `audit` - Auditoría

**Archivos Generados**:
```
01_ddl/00_extensions/
  └── 001_enable_uuid_extension.sql
  └── changelog.yaml

01_ddl/01_schemas/
  └── 001_create_schemas.sql
  └── changelog.yaml
```

### Sprint 1.2: Tablas Core (Completado)

**Tabla 1: security.user**
```sql
-- Estado: ✅ Funcional
-- Registros esperados: 1000s (aprendices + instructores + admin)
-- Índices: DEFAULT (PK en id)

CREATE TABLE "user" (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_number VARCHAR(20) NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date TIMESTAMPZ NOT NULL,
    account_status VARCHAR(20) NOT NULL,
    CONSTRAINT chk_account_status 
    CHECK (account_status IN ('ACTIVE', 'INACTIVE', 'PENDING_CONSENT', 'BLOCKED'))
);
```

**Tabla 2: security.credential**
```sql
-- Estado: ⚠️ CON PROBLEMAS - Requiere corrección inmediata
-- Problema 1: id_user es BIGINT pero debe ser UUID
-- Problema 2: FK referencia a user(id_user) que no existe

CREATE TABLE credential (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    credential_status VARCHAR(20) NOT NULL,
    failed_attempts INTEGER NOT NULL DEFAULT 0,
    id_user BIGINT NOT NULL,  -- ⚠️ DEBE SER UUID
    CONSTRAINT uq_credential_email UNIQUE (email),
    CONSTRAINT chk_credential_status 
    CHECK (credential_status IN ('ACTIVE', 'INACTIVE', 'BLOCKED')),
    CONSTRAINT chk_failed_attempts_non_negative
    CHECK (failed_attempts >= 0),
    CONSTRAINT fk_credential_user
    FOREIGN KEY (id_user) REFERENCES "user"(id_user)  -- ⚠️ REFERENCIA INCORRECTA
);
```

**Archivos Generados**:
```
01_ddl/03_tables/
  ├── 001_user.sql
  ├── 002_credential.sql
  └── changelog.yaml
```

### Sprint 1.3: Rollbacks (Completado)

**Rollbacks Implementados**:

```
05_rollbacks/01_ddl/
  ├── 00_extensions/
  │   └── 001_enable_uuid_extension.rollback.sql
  ├── 01_schemas/
  │   └── 001_create_schemas.rollback.sql
  └── 03_tables/
      ├── 001_create_security_tables.rollback.sql
      └── 002_create_inventory_tables.rollback.sql
```

**Estrategia de Rollback**:
- Cada SQL DDL tiene su `.rollback.sql` correspondiente
- Drop tables en orden inverso
- Drop schemas si están vacíos
- Disable extensions con cuidado

---

## FASE 1.5: Correcciones Críticas (EN PROGRESO)

### Problema de Integridad #1: Tipo Inconsistente

**Descripción**:
- `user.id` → UUID
- `credential.id_user` → BIGINT (❌ Incompatible)

**Impacto**:
- No se pueden insertar registros
- Violaría FK si existiera

**Solución**:
```sql
-- Paso 1: Eliminar FK temporalmente
ALTER TABLE credential DROP CONSTRAINT fk_credential_user;

-- Paso 2: Cambiar tipo
ALTER TABLE credential ALTER COLUMN id_user TYPE UUID USING id_user::uuid;

-- Paso 3: Recrear FK correctamente
ALTER TABLE credential
ADD CONSTRAINT fk_credential_user
  FOREIGN KEY (id_user) REFERENCES "user"(id);
```

**Archivo de Migración**:
- Crear: `01_ddl/03_tables/003_fix_credential_fk.sql`
- Rollback: `05_rollbacks/01_ddl/03_tables/003_fix_credential_fk.rollback.sql`

### Mejoras de Campos (Fase 1.5)

**Tabla: user**

Agregar:
```sql
ALTER TABLE "user" ADD COLUMN created_at TIMESTAMPZ NOT NULL DEFAULT NOW();
ALTER TABLE "user" ADD COLUMN updated_at TIMESTAMPZ NOT NULL DEFAULT NOW();
ALTER TABLE "user" ADD COLUMN is_deleted BOOLEAN NOT NULL DEFAULT FALSE;
```

**Tabla: credential**

Agregar:
```sql
ALTER TABLE credential ADD COLUMN created_at TIMESTAMPZ NOT NULL DEFAULT NOW();
ALTER TABLE credential ADD COLUMN updated_at TIMESTAMPZ NOT NULL DEFAULT NOW();
ALTER TABLE credential ADD COLUMN last_login_at TIMESTAMPZ;
ALTER TABLE credential ADD COLUMN password_reset_at TIMESTAMPZ;
```

**Triggers de Auditoría (opcional en FASE 1.5)**:
```sql
CREATE FUNCTION update_timestamp() RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER update_user_timestamp
  BEFORE UPDATE ON "user"
  FOR EACH ROW
  EXECUTE FUNCTION update_timestamp();
```

---

## FASE 2: Académico - Pre-Planificación

### Tablas a Crear (4 nuevas)

#### 1. academic.program

```
Propósito: Programas de formación SENA
Volumen esperado: 50-100 registros
Crecimiento: Bajo

Columnas:
- id UUID PK
- code VARCHAR(20) UNIQUE
- name VARCHAR(100)
- description TEXT
- duration_weeks INTEGER
- duration_hours INTEGER
- sector VARCHAR(50) (ej: 'Tecnología')
- status ENUM (PLANNING, ACTIVE, DEPRECATED, ARCHIVED)
- created_at, updated_at
- created_by UUID FK → user.id
- updated_by UUID FK → user.id

Índices:
- UNIQUE(code)
- (status)
- (sector)

Validaciones:
- duration_weeks > 0
- duration_hours >= duration_weeks * 40
```

#### 2. academic.course

```
Propósito: Fichas dentro de programas
Volumen esperado: 500-1000 registros/año
Crecimiento: Anual

Columnas:
- id UUID PK
- id_program UUID FK → program.id
- code VARCHAR(30) UNIQUE
- start_date DATE
- end_date DATE
- max_learners INTEGER
- id_instructor UUID FK → user.id
- schedule_type ENUM (MORNING, AFTERNOON, EVENING, WEEKEND)
- status ENUM (PLANNING, ACTIVE, FINISHED, CANCELLED)
- created_at, updated_at

Índices:
- UNIQUE(code)
- (id_program)
- (status, start_date)
- (id_instructor)

Validaciones:
- end_date > start_date
- max_learners > 0
- start_date >= CURRENT_DATE (no cursos retroactivos)
```

#### 3. academic.learner

```
Propósito: Aprendices matriculados
Volumen esperado: 10000+ registros
Crecimiento: Exponencial (100s por mes)

Columnas:
- id UUID PK (mismo que user.id)
- id_course UUID FK → course.id
- id_user UUID FK → user.id
- enrollment_date DATE
- curriculum_status ENUM (NOT_STARTED, IN_PROGRESS, COMPLETED, DROPPED, TRANSFERRED)
- completion_percentage NUMERIC(5,2)
- created_at, updated_at

Índices:
- (id_course, enrollment_date)
- (id_user)
- (curriculum_status)

Validaciones:
- Un aprendiz solo una vez por ficha
- curriculum_status compatible con estado del curso
```

#### 4. academic.instructor

```
Propósito: Instructores del sistema
Volumen esperado: 50-200 registros
Crecimiento: Bajo

Columnas:
- id UUID PK (mismo que user.id)
- id_user UUID FK → user.id (UNIQUE)
- specialization VARCHAR(100)
- professional_title VARCHAR(100)
- active_courses_count INTEGER (calculado)
- status ENUM (ACTIVE, INACTIVE, ON_LEAVE, RETIRED)
- created_at, updated_at

Índices:
- UNIQUE(id_user)
- (status)

Validaciones:
- Instructor con status INACTIVE no asignable a nuevos cursos
```

### Relaciones

```
program (1) ────┐
                ├─→ course (N) ────┐
                                   ├─→ learner (N)
                                   │
                instructor ────────┘

Cardinalidades:
- program (1) : course (N)
- course (1) : learner (N)
- course (1) : instructor (N)
- learner (N) : user (1)
- instructor (N) : user (1)
```

### Procedimientos para FASE 2

```sql
-- Enlistar aprendices de una ficha
SELECT u.first_name, u.last_name, l.enrollment_date
FROM learner l
JOIN "user" u ON u.id = l.id_user
WHERE l.id_course = $1
ORDER BY u.last_name;

-- Verificar capacidad de ficha
SELECT 
    c.code,
    c.max_learners,
    COUNT(l.id) as enrolled,
    (c.max_learners - COUNT(l.id)) as available
FROM course c
LEFT JOIN learner l ON c.id = l.id_course
WHERE c.id = $1
GROUP BY c.id, c.code, c.max_learners;

-- Asignar instructor a curso
UPDATE course SET id_instructor = $1 WHERE id = $2;
UPDATE instructor SET active_courses_count = active_courses_count + 1 
WHERE id_user = $1;
```

---

## FASE 3: Asistencias - Pre-Planificación

### Tablas a Crear (4 nuevas)

#### 1. attendance.environment

```
Propósito: Ambientes donde se registra asistencia
Volumen: 10-50 registros
Tipo: Master data (cambia rara vez)

Columnas:
- id UUID PK
- code VARCHAR(20) UNIQUE
- name VARCHAR(100)
- location VARCHAR(100)
- building_number INTEGER
- floor_number INTEGER
- capacity INTEGER
- has_facial_recognition BOOLEAN DEFAULT true
- device_id VARCHAR(50) (Raspberry Pi serial)
- status ENUM (OPERATIONAL, MAINTENANCE, INACTIVE)
- created_at, updated_at

Índices:
- UNIQUE(code)
- (status)
- (has_facial_recognition)
```

#### 2. attendance.attendance_record

```
Propósito: Registros de entrada/salida
Volumen: 1000s/día (100K+/mes)
Tipo: Fact table (append-only, muy grande)
NOTA: Requiere particionamiento en FASE 5

Columnas:
- id UUID PK
- id_learner UUID FK → learner.id
- id_environment UUID FK → environment.id
- check_in_time TIMESTAMPZ NOT NULL
- check_out_time TIMESTAMPZ (nullable)
- duration_minutes INTEGER (calculado)
- scheduled_time TIMESTAMP
- status ENUM (ON_TIME, LATE, EARLY_DEPARTURE, ABSENCE, MANUAL_OVERRIDE)
- facial_match_score NUMERIC(5,2) (0-100)
- confidence NUMERIC(5,2) (0-100)
- notes TEXT
- created_at TIMESTAMPZ DEFAULT NOW()
- created_by UUID FK → user.id

Índices:
- (id_learner, check_in_time)
- (id_environment, check_in_time)
- (status)
- (check_in_time)
```

#### 3. facial.facial_vector

```
Propósito: Embeddings biométricos
Volumen: 1 por aprendiz (max)
Tipo: Master data

Columnas:
- id UUID PK
- id_learner UUID FK → learner.id (UNIQUE)
- vector_data BYTEA (128-512 float32s)
- vector_dimension INTEGER (128|256|512)
- model_version VARCHAR(20) (ej: 'facenet_2023_v1')
- capture_date TIMESTAMPZ
- quality_score NUMERIC(5,2) (0-100)
- is_primary BOOLEAN DEFAULT true
- created_at, updated_at

Índices:
- UNIQUE(id_learner)
- (is_primary)
```

#### 4. facial.facial_capture

```
Propósito: Auditoría de capturas
Volumen: 1-3/día/aprendiz (puede crecer mucho)
Tipo: Audit table

Columnas:
- id UUID PK
- id_learner UUID FK → learner.id
- image_path VARCHAR(255) (ej: 's3://bucket/captures/2024/...')
- image_hash VARCHAR(64) (SHA256 para deduplicación)
- capture_timestamp TIMESTAMPZ
- device_id VARCHAR(50) (Raspberry Pi serial)
- device_ip INET
- processing_status ENUM (PENDING, PROCESSING, COMPLETED, FAILED)
- model_used VARCHAR(50)
- confidence_score NUMERIC(5,2)
- error_message TEXT (si FAILED)
- created_at, updated_at

Índices:
- (id_learner, capture_timestamp)
- (device_id)
- (processing_status)
```

### Lógica de Flujo

**Flujo: Aprendiz llega al ambiente**

```
1. Raspberry Pi en environment captura rostro
   ↓
2. Envía imagen a servidor FaceID (FastAPI)
   ↓
3. Servidor genera embedding (FaceNet/ArcFace)
   ↓
4. Busca vector más similar en facial.facial_vector
   ↓
5. Si confidence > 95%:
   ├─ Identifica al aprendiz
   ├─ Calcula si es ON_TIME o LATE
   └─ Crea attendance_record
   ↓
6. Si confidence < 95%:
   ├─ Requiere validación manual
   ├─ Aprendiz escanea cédula
   ├─ Operador confirma
   └─ Crea attendance_record con MANUAL_OVERRIDE
   ↓
7. Registra captura en facial_capture para auditoría
```

---

## Estimación de Esfuerzo

| Fase | Tablas | Funciones | Triggers | Índices | Estimado |
|------|--------|-----------|----------|---------|----------|
| 1 | 2 | 0 | 0 | 1 | 3 días |
| 2 | 4 | 3 | 2 | 8 | 1 semana |
| 3 | 4 | 5 | 5 | 12 | 1.5 sem |
| 4 | 1 | 0 | 10 | 0 | 5 días |
| 5 | 0 | 8 | 0 | 20 | 1 semana |

**Total Estimado**: 5-6 semanas (tiempo dedicado)

---

## Criterios de Aceptación por Fase

### FASE 1
- [x] docker-compose levanta sin errores
- [x] 5 schemas creados
- [x] 2 tablas con estructura
- [x] [ ] **Corrección**: Integridad referencial en credential
- [x] Rollbacks funcionan

### FASE 2
- [ ] 4 nuevas tablas creadas
- [ ] Relaciones FK verificadas
- [ ] 100 registros de prueba cargados
- [ ] Queries de ejemplo ejecutadas
- [ ] Indices mejoran búsquedas > 10%

### FASE 3
- [ ] 4 nuevas tablas creadas
- [ ] Integración con Raspberry Pi validada
- [ ] 1000 registros de attendance de prueba
- [ ] Funciones de cálculo de status testeadas
- [ ] Performance < 100ms para queries

### FASE 4
- [ ] Roles creados y asignados
- [ ] Auditoría captura cambios
- [ ] RLS policy verificada
- [ ] Permisos granulares funcionan

### FASE 5
- [ ] Vistas materializadas generan reportes
- [ ] Procedimientos almacenados funcionan
- [ ] Performance < 2s para reportes
- [ ] Datos antiguos archivados correctamente

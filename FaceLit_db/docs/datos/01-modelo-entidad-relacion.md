# Modelo Entidad-Relación (MER)

## Diagrama Conceptual Actual

```
┌──────────────────────────────────────────────────────────────────┐
│                         USUARIO (user)                            │
│                                                                   │
│  • id (UUID PK)                                                  │
│  • document_number (VARCHAR 20)                                  │
│  • first_name (VARCHAR 50)                                       │
│  • last_name (VARCHAR 50)                                        │
│  • birth_date (TIMESTAMPZ)                                       │
│  • account_status (VARCHAR 20: ACTIVE|INACTIVE|PENDING|BLOCKED) │
│                                                                   │
│  Schema: security                                                │
│  Estado: ✅ Producción                                           │
└──────────────────────────────────────────────────────────────────┘
                           1
                           │ Tiene
                           │ (1:N)
                           │
                           ▼
┌──────────────────────────────────────────────────────────────────┐
│                     CREDENCIAL (credential)                       │
│                                                                   │
│  • id (UUID PK)                                                  │
│  • email (VARCHAR 50, UNIQUE)                                    │
│  • password_hash (VARCHAR 255)                                   │
│  • credential_status (VARCHAR 20: ACTIVE|INACTIVE|BLOCKED)       │
│  • failed_attempts (INTEGER ≥ 0)                                 │
│  • id_user (BIGINT FK → user.id_user) ⚠️ REVISAR                 │
│                                                                   │
│  Schema: security                                                │
│  Estado: ✅ Producción (pero con inconsistencias)               │
└──────────────────────────────────────────────────────────────────┘
```

---

## Entidades Implementadas

### 1. USUARIO (`security.user`)

**Propósito**: Registrar información demográfica y de estado de cada usuario del sistema.

**Características**:
- Identificación única por UUID (no secuencial, distribuible)
- Documento de identidad único para validación externa
- Información biográfica básica
- Estado de cuenta con múltiples estados permitidos

**Columnas Detalladas**:

| Columna | Tipo | Restricción | Descripción |
|---------|------|-------------|-------------|
| `id` | UUID | PK, DEFAULT uuid_generate_v4() | Identificador único global |
| `document_number` | VARCHAR(20) | NOT NULL | Cédula/Pasaporte (máximo 20 chars) |
| `first_name` | VARCHAR(50) | NOT NULL | Nombre del usuario |
| `last_name` | VARCHAR(50) | NOT NULL | Apellido del usuario |
| `birth_date` | TIMESTAMPZ | NOT NULL | Fecha de nacimiento con zona horaria |
| `account_status` | VARCHAR(20) | NOT NULL, CHECK | Estado del account |

**Estados Permitidos** (`account_status`):
- `ACTIVE` - Usuario habilitado y funcional
- `INACTIVE` - Usuario deshabilitado temporalmente
- `PENDING_CONSENT` - Usuario registrado pero sin consentimiento informado
- `BLOCKED` - Usuario bloqueado por seguridad

---

### 2. CREDENCIAL (`security.credential`)

**Propósito**: Almacenar credenciales de autenticación vinculadas a usuarios.

**Características**:
- Relación 1:N con usuario (1 usuario → N credenciales)
- Email único por credencial
- Contraseña hasheada (nunca en texto plano)
- Seguimiento de intentos fallidos de login
- Estados independientes de usuario

**Columnas Detalladas**:

| Columna | Tipo | Restricción | Descripción |
|---------|------|-------------|-------------|
| `id` | UUID | PK, DEFAULT uuid_generate_v4() | Identificador único de credencial |
| `email` | VARCHAR(50) | NOT NULL, UNIQUE | Email de acceso (único) |
| `password_hash` | VARCHAR(255) | NOT NULL | Hash seguro de contraseña (bcrypt/scrypt) |
| `credential_status` | VARCHAR(20) | NOT NULL, CHECK | Estado de la credencial |
| `failed_attempts` | INTEGER | NOT NULL, DEFAULT 0, CHECK ≥ 0 | Contador de intentos fallidos |
| `id_user` | BIGINT | NOT NULL, FK | ⚠️ **INCONSISTENCIA**: Referencia a UUID pero es BIGINT |

**Estados Permitidos** (`credential_status`):
- `ACTIVE` - Credencial habilitada y funcional
- `INACTIVE` - Credencial deshabilitada temporalmente
- `BLOCKED` - Credencial bloqueada por seguridad (muchos intentos fallidos)

**Restricciones de Integridad**:
- `uq_credential_email` - Garantiza un email único por base
- `chk_credential_status` - Solo permite valores enumerados
- `chk_failed_attempts_non_negative` - No permite números negativos
- `fk_credential_user` - ⚠️ **REFERENCIA INCORRECTA**: Apunta a `user.id_user` pero no existe

---

## Relaciones Entre Entidades

### Relación: User → Credential

**Tipo**: 1 : N (Uno a Muchos)

**Descripción**:
- Un usuario puede tener múltiples credenciales
- Permite cambio de email/contraseña manteniendo identidad
- Facilita múltiples métodos de autenticación (correo, usuario, etc.)

**Ciclo de Vida**:
```
Usuario creado → Credencial inicial → Cambio de password → Nueva credencial
                                   ↓
                            (antigua puede bloquearse)
```

**Implicaciones de Negocio**:
- Usuario puede tener credencial bloqueada pero status ACTIVE
- Permite recuperación de contraseña sin afectar datos de usuario

---

## ⚠️ INCONSISTENCIAS DETECTADAS

### Problema 1: Tipo de Dato Incoherente

**Ubicación**: `credential.id_user`

**Problema**: 
```sql
-- user.id es UUID
id UUID PRIMARY KEY DEFAULT uuid_generate_v4()

-- credential.id_user es BIGINT (!)
id_user BIGINT NOT NULL,
FOREIGN KEY (id_user) REFERENCES "user"(id_user)
```

**Impacto**:
- Imposible insertar datos sin error de tipo
- Violación de integridad referencial
- Queries ineficientes con conversiones de tipo

**Solución Recomendada**:
```sql
ALTER TABLE credential
  MODIFY id_user UUID NOT NULL;

-- Luego actualizar FK:
ALTER TABLE credential
  DROP CONSTRAINT fk_credential_user;
  
ALTER TABLE credential
  ADD CONSTRAINT fk_credential_user
    FOREIGN KEY (id_user) REFERENCES "user"(id);
```

### Problema 2: Referencia a Columna Inexistente

**Ubicación**: `credential.id_user` → `user.id_user`

**Problema**: 
- Tabla `user` tiene columna `id`, no `id_user`
- Referencia apunta a columna que no existe

**Solución Recomendada**:
```sql
ALTER TABLE credential
  DROP CONSTRAINT fk_credential_user;
  
ALTER TABLE credential
  ADD CONSTRAINT fk_credential_user
    FOREIGN KEY (id_user) REFERENCES "user"(id);
```

---

## Planificación de Entidades Futuras

### Fase 2 (Próxima)

```
academic.program (1) ←──── (N) academic.course
                                      │
                                      ├──→ (N) academic.learner
                                      └──→ (N) academic.instructor


attendance.environment (1) ←──── (N) attendance.record
                                      │
                                      └──→ learner + attendance_time
```

### Fase 3

```
facial.facial_vector (1) ←──── (N) facial.capture
attendance.record (1) ←──── (N) facial.verification_event
```

### Fase 4

```
audit.audit_log ←──── ALL tables (triggers automáticos)
```

---

## Próximos Pasos

1. ✅ **URGENTE**: Corregir inconsistencias en `credential`
2. 📋 Crear script de migración para corregir FK
3. 📋 Agregar campos `created_at`, `updated_at` a ambas tablas
4. 📋 Diseñar tablas de `academic` schema
5. 📋 Implementar triggers de auditoría

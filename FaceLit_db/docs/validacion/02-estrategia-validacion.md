# Estrategia de Validación del Sistema

## Introducción

Este documento describe cómo el sistema FaceLit valida datos en todos los niveles: desde la estructura de la base de datos hasta las reglas de negocio de la aplicación.

---

## Capas de Validación

```
┌─────────────────────────────────────────────┐
│   CAPA 7: Reportes & Auditoría              │
│   (Validación de tendencias, anomalías)     │
├─────────────────────────────────────────────┤
│   CAPA 6: Lógica de Negocio (API)           │
│   (Workflow, ciclos de vida)                │
├─────────────────────────────────────────────┤
│   CAPA 5: Aplicación (Constrains, Rules)    │
│   (Password strength, email format)         │
├─────────────────────────────────────────────┤
│   CAPA 4: Integridad Referencial (FK)       │
│   (Registros relacionados existen)          │
├─────────────────────────────────────────────┤
│   CAPA 3: Restricciones (CHECK, UNIQUE)     │
│   (Valores válidos dentro del dominio)      │
├─────────────────────────────────────────────┤
│   CAPA 2: Tipos de Datos (VARCHAR, UUID)    │
│   (Formato correcto del valor)              │
├─────────────────────────────────────────────┤
│   CAPA 1: Persistencia (PK, NOT NULL)       │
│   (Registro único, no vacio)                │
└─────────────────────────────────────────────┘
```

---

## CAPA 1: Persistencia

**Responsable**: PostgreSQL

**Objetivo**: Garantizar que los datos existan y sean únicos

### Tabla: user

| Validación | SQL | Estado |
|-----------|-----|--------|
| **PK Obligatorio** | `id UUID PRIMARY KEY` | ✅ Implementado |
| **Documento no nulo** | `document_number ... NOT NULL` | ✅ Implementado |
| **Nombre no nulo** | `first_name ... NOT NULL` | ✅ Implementado |
| **Apellido no nulo** | `last_name ... NOT NULL` | ✅ Implementado |
| **Fecha no nula** | `birth_date ... NOT NULL` | ✅ Implementado |
| **Estado no nulo** | `account_status ... NOT NULL` | ✅ Implementado |

### Tabla: credential

| Validación | SQL | Estado |
|-----------|-----|--------|
| **PK Obligatorio** | `id UUID PRIMARY KEY` | ✅ Implementado |
| **Email no nulo** | `email ... NOT NULL` | ✅ Implementado |
| **Hash no nulo** | `password_hash ... NOT NULL` | ✅ Implementado |
| **Status no nulo** | `credential_status ... NOT NULL` | ✅ Implementado |
| **Intentos no nulo** | `failed_attempts INTEGER NOT NULL DEFAULT 0` | ✅ Implementado |
| **FK id_user no nulo** | `id_user ... NOT NULL` | ✅ Implementado |

---

## CAPA 2: Tipos de Datos

**Responsable**: PostgreSQL + Driver JDBC

**Objetivo**: Garantizar que los valores sean del tipo correcto

### Validaciones de Tipo Actuales

| Campo | Tipo BD | Rango | Ejemplo Válido | Ejemplo Inválido |
|-------|---------|-------|----------------|------------------|
| `id` | UUID | 36 caracteres | `550e8400-e29b-41d4-a716-446655440000` | `12345` |
| `document_number` | VARCHAR(20) | 1-20 caracteres | `1053987654` | `10539876541053987654X` (21 chars) |
| `first_name` | VARCHAR(50) | 1-50 caracteres | `Juan` | `$John!@#$%` (símbolos) |
| `email` | VARCHAR(50) | RFC 5322 | `juan@example.com` | `juan@@example.com` (inválido) |
| `password_hash` | VARCHAR(255) | Hasta 255 | `$2b$12$KIX...` (bcrypt) | `password123` (texto plano) |
| `birth_date` | TIMESTAMPZ | -∞ a CURRENT_DATE | `1995-03-15 00:00:00+00` | `2025-12-31` (futuro) |
| `failed_attempts` | INTEGER | Enteros | `0`, `5`, `10` | `3.5` (flotante) |
| `account_status` | VARCHAR(20) | 4 valores | `ACTIVE` | `ACTIVO` (inválido) |

### Problemas Detectados

#### ⚠️ PROBLEMA: Tipo Inconsistente en FK

```
Tabla user:
  id UUID → Ejemplo: 550e8400-e29b-41d4...

Tabla credential:
  id_user BIGINT → No puede referenciar UUID
```

**Impacto**: 
- Imposible insertar datos
- FK violada estructuralmente

**Solución**:
```sql
ALTER TABLE credential 
ALTER COLUMN id_user TYPE UUID USING id_user::uuid;
```

---

## CAPA 3: Restricciones (CHECK, UNIQUE)

**Responsable**: PostgreSQL

**Objetivo**: Garantizar que los valores pertenezcan al dominio permitido

### CHECK Constraints (Enumeraciones)

#### user.account_status

```sql
CONSTRAINT chk_account_status 
CHECK (account_status IN ('ACTIVE', 'INACTIVE', 'PENDING_CONSENT', 'BLOCKED'))
```

**Validación**:
```sql
-- ✅ Válido
INSERT INTO "user" (..., account_status = 'ACTIVE') VALUES (...);

-- ❌ Inválido (violaría CHECK)
INSERT INTO "user" (..., account_status = 'DELETED') VALUES (...);
-- Error: new row for relation "user" violates check constraint "chk_account_status"
```

**Estados Permitidos**:
- `ACTIVE` - Usuario funcional
- `INACTIVE` - Usuario deshabilitado
- `PENDING_CONSENT` - Espera consentimiento
- `BLOCKED` - Bloqueado por seguridad

---

#### credential.credential_status

```sql
CONSTRAINT chk_credential_status 
CHECK (credential_status IN ('ACTIVE', 'INACTIVE', 'BLOCKED'))
```

**Estados Permitidos**:
- `ACTIVE` - Credencial funcional
- `INACTIVE` - Credencial deshabilitada
- `BLOCKED` - Bloqueada por intentos fallidos

---

#### credential.failed_attempts

```sql
CONSTRAINT chk_failed_attempts_non_negative
CHECK (failed_attempts >= 0)
```

**Validación**:
```sql
-- ✅ Válido
UPDATE credential SET failed_attempts = 5 WHERE id = ...;

-- ❌ Inválido (violaría CHECK)
UPDATE credential SET failed_attempts = -1 WHERE id = ...;
-- Error: new row for relation "credential" violates check constraint "chk_failed_attempts_non_negative"
```

### UNIQUE Constraints (Unicidad)

#### credential.email

```sql
CONSTRAINT uq_credential_email UNIQUE (email)
```

**Validación**:
```sql
-- ✅ Válido (primer email)
INSERT INTO credential (email, ...) 
VALUES ('juan@example.com', ...);

-- ❌ Inválido (email duplicado)
INSERT INTO credential (email, ...) 
VALUES ('juan@example.com', ...);
-- Error: duplicate key value violates unique constraint "uq_credential_email"
```

### Restricciones Faltantes (CRÍTICAS)

#### ❌ FALTA: user.document_number UNIQUE

**Riesgo**: Duplicación fraudulenta

**Solución**:
```sql
ALTER TABLE "user" 
ADD CONSTRAINT uq_document_number UNIQUE (document_number);
```

#### ❌ FALTA: birth_date válida

**Riesgo**: Fechas futuras o muy antiguas

**Solución**:
```sql
ALTER TABLE "user"
ADD CONSTRAINT chk_birth_date 
  CHECK (birth_date <= CURRENT_DATE AND birth_date >= '1900-01-01');
```

---

## CAPA 4: Integridad Referencial (Foreign Keys)

**Responsable**: PostgreSQL

**Objetivo**: Garantizar que relaciones entre tablas sean válidas

### credential.id_user → user.id

```sql
CONSTRAINT fk_credential_user
FOREIGN KEY (id_user) REFERENCES "user"(id)
```

**Validación**:
```sql
-- ✅ Válido (user existe)
INSERT INTO credential (id_user, ...) 
VALUES ('550e8400-e29b-41d4-a716-446655440000', ...)
WHERE EXISTS (SELECT 1 FROM "user" WHERE id = '550e8400-e29b-41d4...');

-- ❌ Inválido (user no existe)
INSERT INTO credential (id_user, ...) 
VALUES ('99999999-9999-9999-9999-999999999999', ...);
-- Error: insert or update on table "credential" violates 
-- foreign key constraint "fk_credential_user"
```

**Casos de Uso**:

```sql
-- Obtener credencial de usuario específico
SELECT c.* FROM credential c
WHERE c.id_user = '550e8400-e29b-41d4-a716-446655440000';
-- Solo retorna credenciales cuyo user existe

-- Listar usuarios sin credencial
SELECT u.* FROM "user" u
LEFT JOIN credential c ON u.id = c.id_user
WHERE c.id IS NULL;
-- Usuarios que nunca han creado credencial
```

### ⚠️ PROBLEMA: FK Referencia Inválida

**Actual**:
```sql
FOREIGN KEY (id_user) REFERENCES "user"(id_user)
-- Pero "user" no tiene columna "id_user", tiene "id"
```

**Error Resultante**:
```
ERROR: constraint "fk_credential_user" for table "credential" does not exist
```

**Corrección**:
```sql
ALTER TABLE credential
DROP CONSTRAINT fk_credential_user;

ALTER TABLE credential
ADD CONSTRAINT fk_credential_user
FOREIGN KEY (id_user) REFERENCES "user"(id);
```

---

## CAPA 5: Validación de Aplicación

**Responsable**: API/Backend (Java, Python, Node.js)

**Objetivo**: Validar reglas complejas que SQL no puede

### Password Strength

```
Requisitos:
  1. Mínimo 12 caracteres
  2. Al menos 1 mayúscula (A-Z)
  3. Al menos 1 minúscula (a-z)
  4. Al menos 1 número (0-9)
  5. Al menos 1 símbolo (!@#$%^&*)

Ejemplos:
  ✅ MyPassword123!
  ✅ Sena#2024@Bogota
  ❌ password123 (sin mayúscula)
  ❌ PASSWORD (sin minúscula)
  ❌ Pass123! (menos de 12 caracteres)
```

**Implementación en API**:
```python
import re

def validate_password_strength(password):
    if len(password) < 12:
        raise ValidationError("Mínimo 12 caracteres")
    
    if not re.search(r'[A-Z]', password):
        raise ValidationError("Debe contener mayúscula")
    
    if not re.search(r'[a-z]', password):
        raise ValidationError("Debe contener minúscula")
    
    if not re.search(r'[0-9]', password):
        raise ValidationError("Debe contener número")
    
    if not re.search(r'[!@#$%^&*]', password):
        raise ValidationError("Debe contener símbolo especial")
    
    return True
```

### Email Validation

```
Requisitos (RFC 5322 simplificado):
  1. Formato: usuario@dominio.extensión
  2. No espacios en blanco
  3. Dominio válido
  4. TLD (extensión) de 2+ caracteres

Ejemplos:
  ✅ juan.perez@sena.edu.co
  ✅ m.rodriguez+test@example.com
  ❌ juan@
  ❌ @example.com
  ❌ juan.example.com (falta @)
```

**Implementación en API**:
```python
from email_validator import validate_email, EmailNotValidError

def validate_email_format(email):
    try:
        valid = validate_email(email)
        return valid.email
    except EmailNotValidError as e:
        raise ValidationError(f"Email inválido: {str(e)}")
```

### Nombre Validation

```
Permitidos:
  - Letras (A-Z, a-z, ñ, acentos)
  - Espacios
  - Apóstrofes (')
  - Guiones (-)

Ejemplos:
  ✅ Juan Carlos
  ✅ María José
  ✅ José-Luis López-García
  ✅ Jean-Pierre D'Alembert
  ❌ Juan123 (contiene número)
  ❌ @Juan (contiene símbolo)
```

**Implementación en API**:
```python
import re

def validate_name(name):
    pattern = r"^[A-Za-záéíóúñÁÉÍÓÚÑ\s'-]+$"
    if not re.match(pattern, name):
        raise ValidationError("Nombre contiene caracteres inválidos")
    if len(name) < 2:
        raise ValidationError("Nombre muy corto")
    if len(name) > 50:
        raise ValidationError("Nombre muy largo")
    return True
```

### Documento Validation

```
Formato por País:
  Colombia: 6-10 dígitos (ej: 1053987654)
  Guatemala: 13 caracteres (ej: 1234567890123)
  Otro: Flexible

Validación Actual: Solo longitud (1-20)
Validación Futura: Algoritmo de verificación por país
```

---

## CAPA 6: Lógica de Negocio

**Responsable**: API/Backend + Base de Datos

**Objetivo**: Garantizar consistencia del workflow

### Ciclo de Vida: Usuario

```
PENDING_CONSENT ──(consentimiento)──> ACTIVE
                                         │
                    (desactivación)      │
                                    ↙    ↘
                              INACTIVE    (incidente)
                                         │
                                    BLOCKED
```

**Reglas**:
1. Usuario nuevo siempre comienza en `PENDING_CONSENT`
2. Solo desde `PENDING_CONSENT` se puede ir a `ACTIVE`
3. De `ACTIVE` se puede ir a `INACTIVE` o `BLOCKED`
4. De `BLOCKED` se puede ir a `ACTIVE` (después revisión)
5. De `INACTIVE` se puede volver a `ACTIVE`

**Validación en Trigger**:
```sql
CREATE FUNCTION validate_user_status_transition() RETURNS TRIGGER AS $$
BEGIN
  -- Transiciones permitidas
  IF NEW.account_status = OLD.account_status THEN
    RETURN NEW; -- Sin cambio, permitir
  END IF;

  -- De PENDING_CONSENT solo a ACTIVE
  IF OLD.account_status = 'PENDING_CONSENT' AND NEW.account_status != 'ACTIVE' THEN
    RAISE EXCEPTION 'De PENDING_CONSENT solo se puede pasar a ACTIVE';
  END IF;

  -- De ACTIVE se puede ir a INACTIVE o BLOCKED
  IF OLD.account_status = 'ACTIVE' AND NEW.account_status NOT IN ('INACTIVE', 'BLOCKED') THEN
    RAISE EXCEPTION 'De ACTIVE solo a INACTIVE o BLOCKED';
  END IF;

  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### Ciclo de Vida: Credencial

```
ACTIVE ────(cambio)───> INACTIVE
  │                          │
  │ (5 intentos fallidos)     │ (reactivación)
  └────> BLOCKED <───────────┘
```

**Reglas**:
1. Nueva credencial siempre `ACTIVE`
2. Si `failed_attempts ≥ 5` → Cambiar a `BLOCKED` automáticamente
3. De `BLOCKED` se va a `INACTIVE` (reset password)
4. De `INACTIVE` se va a `ACTIVE` (validación manual)

**Validación en Trigger**:
```sql
CREATE TRIGGER auto_block_credential_on_failed_attempts
AFTER UPDATE OF failed_attempts ON credential
FOR EACH ROW
WHEN (NEW.failed_attempts >= 5 AND OLD.credential_status = 'ACTIVE')
EXECUTE FUNCTION block_credential();

CREATE FUNCTION block_credential() RETURNS TRIGGER AS $$
BEGIN
  NEW.credential_status = 'BLOCKED';
  INSERT INTO audit_log (table_name, operation, record_id, ...)
  VALUES ('credential', 'BLOCKED_AUTO', NEW.id, ...);
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

---

## CAPA 7: Reportes y Anomalías

**Responsable**: Backend + Análisis

**Objetivo**: Detectar patrones anómalos

### Anomalías Detectables

#### Anomalía: Múltiples Intentos Fallidos

```sql
SELECT 
    c.email,
    u.first_name || ' ' || u.last_name as user_name,
    c.failed_attempts,
    COUNT(*) as recent_attempts
FROM credential c
JOIN "user" u ON u.id = c.id_user
WHERE c.failed_attempts >= 3
GROUP BY c.email, u.first_name, u.last_name, c.failed_attempts
ORDER BY c.failed_attempts DESC;

-- Acción: Notificar usuario, ofrecerpassword recovery
```

#### Anomalía: Usuarios Sin Credencial

```sql
SELECT 
    u.id,
    u.first_name || ' ' || u.last_name as user_name,
    u.account_status,
    u.created_at
FROM "user" u
LEFT JOIN credential c ON u.id = c.id_user
WHERE c.id IS NULL
  AND u.account_status = 'ACTIVE'
  AND u.created_at < CURRENT_DATE - INTERVAL '7 days';

-- Acción: Recordar al usuario que configure credencial
```

#### Anomalía: Múltiples Credenciales Activas

```sql
SELECT 
    c1.email,
    u.first_name || ' ' || u.last_name as user_name,
    COUNT(*) as active_credentials
FROM credential c1
JOIN "user" u ON u.id = c1.id_user
WHERE c1.credential_status = 'ACTIVE'
GROUP BY c1.id_user, u.first_name, u.last_name, c1.email
HAVING COUNT(*) > 1;

-- Acción: Investigar, consolidar credenciales
```

---

## Checklist de Validación

### Antes de Producción

- [ ] **CRÍTICO**: Corregir FK en credential (type + reference)
- [ ] **CRÍTICO**: Agregar UNIQUE en document_number
- [ ] **IMPORTANTE**: Agregar CHECK en birth_date
- [ ] Todos los CHECK constraints funcionan
- [ ] FK se valida correctamente
- [ ] Ciclos de vida de entidades implementados
- [ ] Triggers de auditoría funcionan
- [ ] Tests de integridad al 100%
- [ ] Documentación revisada por equipo
- [ ] Capacitación del equipo completada

### Durante Desarrollo

- [ ] Cada tabla tiene descripción en comentario SQL
- [ ] Cada constraint tiene una razón documentada
- [ ] Queries de validación exist
- [ ] Hay script de verificación de integridad

### Monitoreo Continuo

- [ ] Query de anomalías ejecutada diariamente
- [ ] Alertas de violaciones de constraint configuradas
- [ ] Logs de cambios enviados a auditoría
- [ ] Métricas de data quality en dashboard

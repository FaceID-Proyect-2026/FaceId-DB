# Estrategia de Validación

## Introducción

La validación en FaceLit ocurre en múltiples capas: DDL (estructura), DML (datos), lógica de negocio e integridad referencial.

---

## Niveles de Validación

### Nivel 1: Validación Estructural (DDL)

**Responsable**: Base de datos (constraints)

**Ejemplos en Implementación Actual**:

1. **Check Constraints** (Enumeraciones)
   ```sql
   CONSTRAINT chk_account_status 
   CHECK (account_status IN ('ACTIVE', 'INACTIVE', 'PENDING_CONSENT', 'BLOCKED'))
   ```
   - Garantiza solo valores válidos en `user.account_status`
   - Ejecutado en INSERTS/UPDATES

2. **Primary Keys**
   ```sql
   id UUID PRIMARY KEY DEFAULT uuid_generate_v4()
   ```
   - Garantiza unicidad de cada registro
   - Imposibilita duplicados

3. **Foreign Keys** (Integridad Referencial)
   ```sql
   FOREIGN KEY (id_user) REFERENCES "user"(id)
   ```
   - ⚠️ **ACTUALMENTE ROTO** - Necesita corrección
   - Una vez corregido: garantiza que cada `id_user` existe en `user`

4. **Unique Constraints**
   ```sql
   CONSTRAINT uq_credential_email UNIQUE (email)
   ```
   - Un email por credencial
   - Imposibilita direcciones duplicadas

5. **Not Null**
   ```sql
   document_number VARCHAR(20) NOT NULL
   ```
   - Campo requerido
   - Imposibilita valores NULL

### Nivel 2: Validación de Tipos de Dato

**Responsable**: Base de datos + aplicación

**Validaciones Actuales**:

| Campo | Tipo | Rango | Validación |
|-------|------|-------|-----------|
| `id` | UUID | 36 caracteres | Formato UUID v4 |
| `document_number` | VARCHAR(20) | 1-20 caracteres | No nulo |
| `first_name` | VARCHAR(50) | 1-50 caracteres | No nulo, sin números |
| `email` | VARCHAR(50) | RFC 5322 | Formato válido, único |
| `password_hash` | VARCHAR(255) | 255 caracteres | bcrypt o scrypt |
| `birth_date` | TIMESTAMPZ | -∞ a NOW() | Fecha válida, con zona TZ |
| `failed_attempts` | INTEGER | 0-∞ | ≥ 0 (verificado por CHECK) |
| `account_status` | VARCHAR(20) | 4 valores fijos | Enum (CHECK) |

---

## Reglas de Integridad de Negocio

### Regla RI-001: Ciclo de Vida de Usuario

**Estado**: PENDING_CONSENT → ACTIVE → INACTIVE → BLOCKED

```
PENDING_CONSENT ────────────────────┐
    │                                │
    ├─→ ACTIVE (después consentimiento)
    │      ├─→ INACTIVE (desactivación)
    │      └─→ BLOCKED (violación de política)
    │
    └─ (expiración) → BLOCKED
```

**Validación**:
```sql
-- No permitir transiciones inválidas
-- Implementar en trigger
IF NEW.account_status = 'BLOCKED' AND OLD.account_status = 'PENDING_CONSENT' THEN
  RAISE EXCEPTION 'Invalid status transition';
END IF;
```

### Regla RI-002: Coherencia User + Credential

**Invariante**: 
- Si `user.account_status = 'BLOCKED'` → Usuario NO puede loguearse
- Si `credential.credential_status = 'BLOCKED'` → Usuario NO puede loguearse
- Si `credential.failed_attempts ≥ 5` → Auto-bloquear credencial

**Validación Lógica**:
```sql
SELECT * FROM credential c
JOIN "user" u ON u.id = c.id_user
WHERE c.credential_status = 'ACTIVE'
  AND u.account_status = 'ACTIVE'
  AND c.failed_attempts < 5;
-- Solo estos pueden autenticarse
```

### Regla RI-003: Documento Único por Usuario

**Invariante**: No dos usuarios con mismo `document_number`

**Validación**: 
```sql
ALTER TABLE "user" 
ADD CONSTRAINT uq_document_number UNIQUE (document_number);
```

**Falta Implementar**:
```sql
-- Actualmente NO existe UNIQUE en document_number
-- Permitiría duplicados fraudulentos
```

### Regla RI-004: Email Único Globalmente

**Invariante**: Un email → Una credencial → Un usuario

**Validación**: ✅ Implementada
```sql
CONSTRAINT uq_credential_email UNIQUE (email)
```

### Regla RI-005: Fecha de Nacimiento Válida

**Invariante**: 
- `birth_date` ≤ CURRENT_DATE (no futuras)
- `birth_date` ≥ '1900-01-01' (razonable)
- Edad mínima (SENA): 18 años

**Validación**: ✅ Parcialmente (CHECK en BD)
```sql
-- Falta implementar:
CONSTRAINT chk_birth_date 
CHECK (birth_date <= CURRENT_DATE 
  AND birth_date >= '1900-01-01'
  AND AGE(CURRENT_DATE, birth_date) >= INTERVAL '18 years')
```

---

## Estrategia de Validación por Operación

### INSERT: Crear Nuevo Usuario

**Caso 1: Usuario Auto-Registrado**

```
Entrada: {documento, nombre, apellido, fecha_nacimiento}
    ↓
1. Validación de Integridad:
   ├─ Documento válido (no vacío, < 20 caracteres)
   ├─ Nombre válido (no vacío, < 50 caracteres)
   ├─ Apellido válido (no vacío, < 50 caracteres)
   └─ Fecha de nacimiento válida (≤ hoy, ≥ 1900, edad ≥ 18)
    ↓
2. Validación de Negocio:
   ├─ ¿Existe usuario con mismo documento? NO
   ├─ ¿Pasó verificación de identidad SENA? SÍ (asumido)
   └─ ¿Tiene consentimiento informado? NO
    ↓
3. Crear registro:
   INSERT INTO "user" (..., account_status = 'PENDING_CONSENT')
    ↓
4. Enviar correo de confirmación
    ↓
5. Retornar: {user_id, estado = 'PENDING_CONSENT'}
```

**Queries de Validación**:
```sql
-- Verificar documento duplicado
SELECT id FROM "user" WHERE document_number = 'VALOR_INGRESO';

-- Edad válida
SELECT AGE(CURRENT_DATE, TIMESTAMP 'VALOR_INGRESO');

-- Insertar (si validaciones pasan)
INSERT INTO "user" (...) VALUES (...);
```

### INSERT: Crear Credencial

```
Entrada: {user_id, email, password}
    ↓
1. Validación de Integridad:
   ├─ Email válido (formato RFC)
   ├─ Password fuerte (mín 12 chars, mayús, minús, números, símbolos)
   └─ user_id existe en user
    ↓
2. Validación de Negocio:
   ├─ ¿User.account_status es PENDING_CONSENT? Esperar consentimiento
   ├─ ¿Ya existe credencial activa? Archivarlo
   └─ ¿Email único? SÍ
    ↓
3. Hash de contraseña con bcrypt (cost=12):
   password_hash = bcrypt(password)
    ↓
4. Crear registro:
   INSERT INTO credential (...) VALUES (...)
    ↓
5. Retornar: {credential_id, estado = 'ACTIVE'}
```

### UPDATE: Cambiar Estado de Usuario

```
Entrada: {user_id, nuevo_estado}
    ↓
1. Validación de Autorización:
   ├─ ¿Usuario logueado es admin? SÍ
   └─ ¿Tiene permiso para modificar usuarios? SÍ
    ↓
2. Validación de Transición:
   ├─ ¿Estado actual permite transición a nuevo_estado?
   │  Si NO → Rechazar
   └─ (Ver tabla de transiciones)
    ↓
3. Validación de Datos:
   └─ ¿nuevo_estado es válido? SÍ (CHECK en BD)
    ↓
4. Ejecutar:
   UPDATE "user" SET account_status = nuevo_estado WHERE id = user_id
    ↓
5. Auditoría:
   INSERT INTO audit_log (usuario, operación, valores_anteriores, nuevos)
    ↓
6. Retornar: {usuario_actualizado}
```

### UPDATE: Incrementar Intentos Fallidos

```
Entrada: {email, motivo='login_fallido'}
    ↓
1. Validación:
   ├─ Email existe en credential? SÍ
   └─ credential_status es ACTIVE? SÍ
    ↓
2. Incrementar:
   UPDATE credential 
   SET failed_attempts = failed_attempts + 1
   WHERE email = email_ingreso
    ↓
3. Verificar límite:
   IF failed_attempts >= 5 THEN
     UPDATE credential SET credential_status = 'BLOCKED'
     RAISE ALERT 'Cuenta bloqueada'
   ENDIF
    ↓
4. Retornar: {intentos_restantes = 5 - failed_attempts}
```

---

## Validaciones por Implementar (CRÍTICAS)

### Problema #1: Falta UNIQUE en document_number

**Riesgo**: Duplicados fraudulentos

**Solución**:
```sql
ALTER TABLE "user" 
ADD CONSTRAINT uq_document_number UNIQUE (document_number);
```

**Migración**:
```sql
-- Primero verificar si hay duplicados
SELECT document_number, COUNT(*)
FROM "user"
GROUP BY document_number
HAVING COUNT(*) > 1;

-- Si hay → Resolver manualmente
-- Si no → Aplicar constraint
```

### Problema #2: Validación de Fecha de Nacimiento

**Riesgo**: Edades inválidas (negativas, futuras)

**Solución**:
```sql
ALTER TABLE "user" DROP CONSTRAINT chk_account_status;
ALTER TABLE "user"
ADD CONSTRAINT chk_account_status 
  CHECK (account_status IN ('ACTIVE', 'INACTIVE', 'PENDING_CONSENT', 'BLOCKED')),
ADD CONSTRAINT chk_birth_date
  CHECK (birth_date <= CURRENT_DATE 
    AND birth_date >= '1900-01-01')
;
```

### Problema #3: Corregir FK en Credential

**Riesgo**: Inconsistencia referencial

**Solución**: (Ya documentada arriba)

---

## Validaciones en Aplicación (Futura)

Estas validaciones deben implementarse en la capa de aplicación (API):

### Password Strength

```
Mínimo 12 caracteres
Debe incluir:
  - Mayúsculas (A-Z)
  - Minúsculas (a-z)
  - Números (0-9)
  - Símbolos (!@#$%^&*)

Ejemplos válidos:
  ✅ MyPass123!
  ✅ Sena#2024@Bogota
  
Ejemplos inválidos:
  ❌ password (demasiado débil)
  ❌ 12345678 (solo números)
```

### Email Validation

```
Formato RFC 5322 (simplificado):
  usuario@dominio.extensión

Ejemplos válidos:
  ✅ juan.perez@sena.edu.co
  ✅ m.rodriguez+test@example.com
  
Ejemplos inválidos:
  ❌ juan@
  ❌ @example.com
  ❌ juan.example.com (falta @)
```

### Nombre Validación

```
Permitidos: Letras, espacios, apóstrofes, guiones
Ejemplos válidos:
  ✅ Juan Carlos
  ✅ María José O'Brien
  ✅ José-Luis López-García

Inválidos:
  ❌ Juan123 (contiene números)
  ❌ @Juan (contiene símbolos)
```

---

## Plan de Testing por Fase

### FASE 1: Validaciones Actuales

**Tests Unitarios Necesarios**:

```python
def test_user_creation():
    # Usuario válido
    user = create_user(
        document='1053987654',
        first_name='Juan',
        last_name='Pérez',
        birth_date='1995-03-15',
        account_status='PENDING_CONSENT'
    )
    assert user.id is not None
    assert user.account_status == 'PENDING_CONSENT'

def test_document_duplicate():
    # Crear dos con mismo documento debe fallar
    create_user(document='1053987654', ...)
    with pytest.raises(IntegrityError):
        create_user(document='1053987654', ...)

def test_invalid_account_status():
    # Status inválido debe fallar
    with pytest.raises(CheckViolationError):
        create_user(account_status='INVALID_STATUS', ...)

def test_credential_email_unique():
    # Email duplicado debe fallar
    create_credential(email='juan@example.com', ...)
    with pytest.raises(IntegrityError):
        create_credential(email='juan@example.com', ...)

def test_credential_fk_integrity():
    # Referencia a usuario inexistente debe fallar
    with pytest.raises(ForeignKeyViolationError):
        create_credential(id_user=uuid.uuid4(), ...)
```

### FASE 2: Validaciones Académicas

**Tests Adicionales**:
- Ciclo de vida de cursos
- Capacidad máxima de fichas
- Solapamiento de horarios

### Validaciones en SQL

**Query de Auditoría**:
```sql
-- Verificar integridad completa
SELECT 
    'user' as tabla,
    COUNT(*) as total_registros,
    COUNT(DISTINCT document_number) as documentos_unicos,
    COUNT(*) - COUNT(DISTINCT document_number) as duplicados
FROM "user"

UNION ALL

SELECT 
    'credential' as tabla,
    COUNT(*) as total_registros,
    COUNT(DISTINCT email) as emails_unicos,
    COUNT(*) - COUNT(DISTINCT email) as duplicados
FROM credential;
```

---

## Checklist de Validación Antes de Producción

- [ ] Corrección de FK en credential (CRÍTICO)
- [ ] UNIQUE en document_number (CRÍTICO)
- [ ] Validación de birth_date (fecha futura/pasada)
- [ ] Triggers de auditoría implementados
- [ ] Todas las restricciones CHECK funcionan
- [ ] Tests unitarios pasan (100%)
- [ ] Tests de integridad pasan
- [ ] Rollbacks verificados
- [ ] Documentación de validaciones completa
- [ ] Capacitación del equipo completada

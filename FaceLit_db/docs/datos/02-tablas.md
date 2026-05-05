# Especificación Detallada de Tablas

## Estado Actual: 2 Tablas Activas

---

## Tabla: `security.user`

### Descripción General

Almacena información demográfica y de estado de todos los usuarios del sistema FaceLit.

### Definición SQL Actual

```sql
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

### Diccionario de Datos

| Columna | Tipo | Null | Default | Descripción | Restricciones |
|---------|------|------|---------|-------------|---------------|
| `id` | UUID | NO | uuid_generate_v4() | ID único global | PK |
| `document_number` | VARCHAR(20) | NO | - | Documento de identidad | Único, requerido |
| `first_name` | VARCHAR(50) | NO | - | Nombre del usuario | Requerido |
| `last_name` | VARCHAR(50) | NO | - | Apellido del usuario | Requerido |
| `birth_date` | TIMESTAMPZ | NO | - | Fecha de nacimiento | Requerido, con TZ |
| `account_status` | VARCHAR(20) | NO | - | Estado de la cuenta | CHECK: 4 valores |

### Estados Permitidos: `account_status`

```
┌─────────────────────────────────────────────────────────────┐
│ ACTIVE                                                      │
│ → Usuario completamente funcional y autorizado              │
│ → Puede autenticarse y usar el sistema                      │
│ → Asistencias son registradas normalmente                   │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ INACTIVE                                                    │
│ → Usuario temporalmente deshabilitado                       │
│ → No puede autenticarse                                     │
│ → Pero los datos se conservan para auditoría                │
│ → Puede reactivarse sin perder historial                    │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ PENDING_CONSENT                                             │
│ → Usuario registrado pero sin consentimiento informado      │
│ → No puede autenticarse hasta consentir                     │
│ → Workflow: PENDING_CONSENT → ACTIVE                        │
│ → Obligatorio por regulaciones de privacidad                │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ BLOCKED                                                     │
│ → Usuario bloqueado por incidentes de seguridad             │
│ → Requiere intervención administrativa para desbloquear     │
│ → Auditoría completa de por qué fue bloqueado               │
│ → Ejemplo: Múltiples intentos de suplantación               │
└─────────────────────────────────────────────────────────────┘
```

### Ejemplo de Datos

```sql
INSERT INTO "user" (document_number, first_name, last_name, birth_date, account_status)
VALUES 
  ('1053987654', 'Juan', 'Pérez', '1995-03-15 00:00:00+00', 'ACTIVE'),
  ('1087654321', 'María', 'Rodríguez', '1998-07-22 00:00:00+00', 'ACTIVE'),
  ('1090123456', 'Carlos', 'López', '1996-11-10 00:00:00+00', 'PENDING_CONSENT');
```

### Caso de Uso: Crear Usuario Nuevo

**Flujo**:
1. Sistema registra nuevo aprendiz en SENA
2. Crea tupla en `user` con `account_status = 'PENDING_CONSENT'`
3. Envía enlace de consentimiento por correo
4. Usuario acepta → `account_status = 'ACTIVE'`
5. Se crea credencial en tabla `credential`

**Queries**:
```sql
-- Usuarios activos
SELECT * FROM "user" WHERE account_status = 'ACTIVE';

-- Usuarios pendientes de consentimiento
SELECT * FROM "user" WHERE account_status = 'PENDING_CONSENT';

-- Buscar usuario por documento
SELECT * FROM "user" WHERE document_number = '1053987654';
```

---

## Tabla: `security.credential`

### Descripción General

Almacena credenciales de autenticación (email, contraseña) vinculadas a usuarios.

**NOTA**: Tabla contiene inconsistencias que deben corregirse (ver sección "Problemas Conocidos").

### Definición SQL Actual

```sql
CREATE TABLE credential (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    credential_status VARCHAR(20) NOT NULL,
    failed_attempts INTEGER NOT NULL DEFAULT 0,
    id_user BIGINT NOT NULL,
    CONSTRAINT uq_credential_email UNIQUE (email),
    CONSTRAINT chk_credential_status 
    CHECK (credential_status IN ('ACTIVE', 'INACTIVE', 'BLOCKED')),
    CONSTRAINT chk_failed_attempts_non_negative
    CHECK (failed_attempts >= 0),
    CONSTRAINT fk_credential_user
    FOREIGN KEY (id_user) REFERENCES "user"(id_user)
);
```

### Diccionario de Datos

| Columna | Tipo | Null | Default | Descripción | Restricciones |
|---------|------|------|---------|-------------|---------------|
| `id` | UUID | NO | uuid_generate_v4() | ID único de credencial | PK |
| `email` | VARCHAR(50) | NO | - | Email de acceso | UNIQUE, requerido |
| `password_hash` | VARCHAR(255) | NO | - | Hash bcrypt/scrypt | Requerido, nunca texto |
| `credential_status` | VARCHAR(20) | NO | - | Estado de credencial | CHECK: 3 valores |
| `failed_attempts` | INTEGER | NO | 0 | Intentos fallidos | ≥ 0, autoincremnta en login fallido |
| `id_user` | BIGINT | NO | - | Referencia a usuario | ⚠️ FK INCONSISTENTE |

### Estados Permitidos: `credential_status`

```
┌─────────────────────────────────────────────────────────────┐
│ ACTIVE                                                      │
│ → Credencial válida y funcional                             │
│ → Usuario puede autenticarse                                │
│ → Si failed_attempts < límite                               │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ INACTIVE                                                    │
│ → Credencial deshabilitada (ej: cambio de email)            │
│ → No permite autenticación                                  │
│ → Puede reactivarse o remplazarse por nueva                 │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ BLOCKED                                                     │
│ → Credencial bloqueada por seguridad                        │
│ → failed_attempts ≥ límite permitido (típicamente 5)        │
│ → Requiere reset de contraseña para desbloquear             │
│ → También bloquea si account_status es BLOCKED              │
└─────────────────────────────────────────────────────────────┘
```

### Relación con `user`

**Tipo**: 1:N (Un usuario → Muchas credenciales)

**Ventajas**:
- Usuario puede cambiar email/contraseña sin perder identidad
- Historial de cambios de credenciales
- Múltiples métodos de autenticación posibles

**Ejemplo**:
```
user {id: abc123} 
  ├─ credential {email: juan@example.com, status: ACTIVE}
  ├─ credential {email: juan.perez@sena.edu.co, status: INACTIVE} 
  └─ credential {email: jperez2024@gmail.com, status: INACTIVE}
```

### Ejemplo de Datos

```sql
-- Primero crear usuario
INSERT INTO "user" (...) VALUES (...);

-- Luego crear credencial (una vez se corrija FK)
INSERT INTO credential (email, password_hash, credential_status, id_user)
VALUES 
  ('juan@example.com', 
   '$2b$12$KIX...', 
   'ACTIVE',
   (SELECT id FROM "user" WHERE document_number = '1053987654'));
```

### Caso de Uso: Login Exitoso

**Flujo**:
1. Usuario ingresa email + contraseña
2. Sistema busca email en `credential`
3. Verifica hash con bcrypt
4. Si coincide y `credential_status = 'ACTIVE'` → Acceso permitido
5. Resetea `failed_attempts = 0`

**Query**:
```sql
SELECT * FROM credential 
WHERE email = 'juan@example.com' 
  AND credential_status = 'ACTIVE'
  AND failed_attempts < 5;
```

### Caso de Uso: Login Fallido (Incrementar Intentos)

**Flujo**:
1. Usuario ingresa email + contraseña incorrecta
2. Sistema incrementa `failed_attempts`
3. Si `failed_attempts = 5` → Cambiar status a `BLOCKED`
4. Notificar usuario por email

**Query**:
```sql
UPDATE credential 
SET failed_attempts = failed_attempts + 1
WHERE email = 'juan@example.com';

-- Si llega a 5:
UPDATE credential 
SET credential_status = 'BLOCKED'
WHERE email = 'juan@example.com' 
  AND failed_attempts >= 5;
```

---

## ⚠️ Problemas Conocidos

### 1. Tipo Inconsistente en FK

**Problema**: 
```
user.id → UUID
credential.id_user → BIGINT ✗
```

**Impacto**: 
- Las inserciones fallarán por tipo incompatible
- La tabla no funciona actualmente

**Corrección Necesaria**:
```sql
ALTER TABLE credential ALTER COLUMN id_user TYPE UUID USING id_user::uuid;
```

### 2. Referencia a Columna Inexistente

**Problema**:
```
FOREIGN KEY (id_user) REFERENCES "user"(id_user)
-- Pero "user" no tiene columna "id_user", tiene "id"
```

**Corrección Necesaria**:
```sql
ALTER TABLE credential
DROP CONSTRAINT fk_credential_user;

ALTER TABLE credential
ADD CONSTRAINT fk_credential_user
  FOREIGN KEY (id_user) REFERENCES "user"(id);
```

---

## Mejoras Planeadas para Ambas Tablas

### Próxima Versión (v0.2)

**Añadir**:
- ✅ `created_at TIMESTAMPZ DEFAULT NOW()`
- ✅ `updated_at TIMESTAMPZ DEFAULT NOW()`
- ✅ `is_deleted BOOLEAN DEFAULT FALSE` (soft deletes)
- ✅ Índices en campos de búsqueda frecuente
- ✅ Trigger de auditoría

**Mejorar**:
- 🔄 Email: aumentar a VARCHAR(100)
- 🔄 Documento: definir formato específico (regex)
- 🔄 Nombres: permitir caracteres especiales (ñ, acentos)

### Versión (v0.3+)

**Seguridad**:
- 🔔 2FA (autenticación de dos factores)
- 🔔 Recovery codes
- 🔔 Histórico de logins

**RGPD**:
- 🔔 Campo de consentimiento de datos
- 🔔 Campo de retención de datos
- 🔔 Derecho al olvido (data purging)

---

## Scripts de Consulta Útiles

### Obtener Datos Completos de Usuario + Credencial

```sql
SELECT 
    u.id as user_id,
    u.document_number,
    u.first_name || ' ' || u.last_name as full_name,
    u.account_status,
    c.email,
    c.credential_status,
    c.failed_attempts,
    CASE 
        WHEN u.account_status != 'ACTIVE' THEN 'User blocked'
        WHEN c.credential_status != 'ACTIVE' THEN 'Credential blocked'
        WHEN c.failed_attempts >= 5 THEN 'Too many attempts'
        ELSE 'Can login'
    END as access_status
FROM "user" u
LEFT JOIN credential c ON u.id = c.id_user;
```

### Usuarios Sin Credencial

```sql
SELECT u.*, 
       (SELECT COUNT(*) FROM credential WHERE id_user = u.id) as credential_count
FROM "user" u
WHERE NOT EXISTS (SELECT 1 FROM credential WHERE id_user = u.id);
```

### Credenciales Bloqueadas

```sql
SELECT 
    u.first_name || ' ' || u.last_name as user_name,
    c.email,
    c.failed_attempts,
    c.credential_status
FROM credential c
JOIN "user" u ON u.id = c.id_user
WHERE c.credential_status = 'BLOCKED';
```

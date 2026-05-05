# Esquemas (Schemas) de la Base de Datos

## Visión General

La base de datos FaceLit utiliza 5 esquemas independientes para separar responsabilidades funcionales y facilitar la gestión de permisos.

---

## Estructura de Schemas

### 1. `security`

**Responsabilidad**: Autenticación, autorización y gestión de accesos

**Tablas Actuales**:
- `user` - Información de usuarios del sistema
- `credential` - Credenciales y autenticación

**Futuro**:
- Roles y asignaciones de roles
- Políticas de acceso
- Tokens de sesión
- Intentos fallidos de login

**Propósito de Negocio**:
- Validar identidad antes de acceder al sistema
- Gestionar permisos por rol
- Mantener historial de accesos

---

### 2. `academic`

**Responsabilidad**: Gestión de la estructura académica

**Tablas Actuales**:
- (Vacío - en diseño)

**Futuro**:
- `program` - Programas de formación
- `course` - Fichas o cursos
- `learner` - Aprendices
- `instructor` - Instructores

**Propósito de Negocio**:
- Organizar estructura educativa SENA
- Agrupar aprendices por ficha
- Asignar instructores

---

### 3. `attendance`

**Responsabilidad**: Control y registro de asistencias

**Tablas Actuales**:
- (Vacío - en diseño)

**Futuro**:
- `attendance_record` - Registros de entrada/salida
- `attendance_status` - Estados posibles (puntual, tardío, ausente)
- `environment` - Ambientes de formación

**Propósito de Negocio**:
- Registrar cada entrada y salida
- Clasificar puntualidad automáticamente
- Generar reportes de asistencia

---

### 4. `facial`

**Responsabilidad**: Biometría y reconocimiento facial

**Tablas Actuales**:
- (Vacío - en diseño)

**Futuro**:
- `facial_vector` - Vectores biométricos por aprendiz
- `facial_capture` - Capturas de rostro
- `biometric_sync` - Sincronización desde Raspberry Pi

**Propósito de Negocio**:
- Almacenar embeddings faciales (from modelo ML)
- Registrar capturas para auditoría
- Mantener histórico de cambios faciales

---

### 5. `audit`

**Responsabilidad**: Auditoría y trazabilidad

**Tablas Actuales**:
- (Vacío - en diseño)

**Futuro**:
- `audit_log` - Registro de cambios en tablas críticas
- `audit_user_changes` - Cambios en usuarios
- `audit_attendance_changes` - Cambios en asistencias

**Propósito de Negocio**:
- Rastrear quién hizo qué y cuándo
- Cumplir normativas de auditoría
- Investigar discrepancias

---

## Relaciones Entre Esquemas

```
┌──────────────┐
│   security   │ (User / Credentials)
├──────────────┤
       │
       ├──────→ academic (Learner belongs to Course)
       ├──────→ attendance (User creates attendance)
       └──────→ facial (User has facial vectors)
       
       
┌──────────────┐
│   academic   │ (Programs, Courses, Learners)
├──────────────┤
       │
       └──────→ attendance (Learner attends)
       

┌──────────────┐
│  attendance  │ (Attendance records)
├──────────────┤
       │
       ├──────→ audit (Changes logged)
       └──────→ facial (For verification)


┌──────────────┐
│    facial    │ (Biometric data)
├──────────────┤
       │
       └──────→ audit (Access to biometrics logged)


┌──────────────┐
│    audit     │ (Central logging)
├──────────────┤
       │
       └──────→ ALL schemas (Logs changes)
```

---

## Permisos por Esquema

*Por definir en fase de DCL*

Planeado:
- **Rol `attendee_reader`**: Acceso solo lectura a `security`, `academic`, `attendance`
- **Rol `attendance_recorder`**: Escritura en `attendance`, lectura en `security` y `academic`
- **Rol `admin`**: Acceso completo a todos los esquemas
- **Rol `audit_reader`**: Solo lectura en `audit`

---

## Nombrado de Convenciones

- **Tablas**: `snake_case` (ej: `facial_vector`)
- **Columnas**: `snake_case` (ej: `created_at`)
- **Esquemas**: `lowercase` (ej: `security`)
- **Primarias**: `id` (UUID por defecto)
- **Foráneas**: `id_<tabla_referenciada>` (ej: `id_user`)
- **Timestamps**: `created_at`, `updated_at`
- **Flags booleanos**: `is_<condición>` (ej: `is_active`)

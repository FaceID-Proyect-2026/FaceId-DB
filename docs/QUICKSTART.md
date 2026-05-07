# Guía Rápida de Inicio - FaceLit DB

**Bienvenido a FaceLit DB** - Sistema de control de asistencia por reconocimiento facial para el SENA.

Este documento te ayudará a entender rápidamente la estructura del proyecto.

---

## ⚡ En 5 Minutos

### ¿Qué es este proyecto?

FaceLit es un sistema que **automatiza el registro de asistencia** usando reconocimiento facial. Reemplaza las listas de Excel con un proceso automático que:

1. 📷 Captura rostro del aprendiz (Raspberry Pi)
2. 🔍 Identifica quién es mediante embeddings biométricos
3. ⏰ Registra hora de entrada/salida
4. 📊 Clasifica como: puntual, tardío o ausente
5. 📈 Genera reportes automáticos

**Este repositorio gestiona solo la base de datos**: estructura, datos y lógica.

---

### ¿Cuál es la estructura actual?

```
FaceLit_db/
├── changelog-master.yaml          ← Archivo maestro de Liquibase
├── docker-compose.yml             ← Infraestructura (PostgreSQL + Liquibase)
├── 01_ddl/                        ← Estructura (DDL = Data Definition)
│   ├── 00_extensions/             ├─ UUID habilitado ✅
│   ├── 01_schemas/                ├─ 5 schemas creados ✅
│   └── 03_tables/                 └─ 2 tablas (user, credential) ✅
├── 02_dml/                        ← Datos (DML = Data Manipulation)
├── 03_dcl/                        ← Permisos (DCL = Data Control)
├── 04_tcl/                        ← Transacciones (TCL = Transaction Control)
├── 05_rollbacks/                  ← Reversiones
└── docs/                          ← Documentación completa
    ├── arquitectura/              ├─ Visión general, schemas
    ├── datos/                     ├─ Tablas, relaciones
    ├── planes/                    ├─ Roadmap, fases
    └── validacion/                └─ Reglas, estrategia
```

---

### ¿Qué tablas existen?

**Actualmente: 2 tablas**

1. **security.user** - Usuarios del sistema
   - Campos: id, documento, nombre, apellido, fecha_nacimiento, estado
   - Estado: ✅ Funcional

2. **security.credential** - Credenciales de autenticación
   - Campos: id, email, password_hash, estado, intentos_fallidos
   - Estado: ⚠️ Tiene problemas de integridad (ver abajo)

**Futuro**: 20+ tablas (academic, attendance, facial, audit schemas)

---

## 🚨 Problemas Críticos Detectados

### Problema 1: Tipo Inconsistente en FK

```
credential.id_user es BIGINT ← ❌ Debe ser UUID
user.id es UUID ← No coinciden
```

**Impacto**: No se pueden insertar datos en credential.

**Solución Inmediata**:
```sql
ALTER TABLE credential ALTER COLUMN id_user TYPE UUID;
```

---

### Problema 2: Referencia Inválida

```
credential.id_user → references user.id_user ← ❌ Esa columna no existe
```

**Debe referenciar**: `user.id`

**Solución Inmediata**:
```sql
ALTER TABLE credential
DROP CONSTRAINT fk_credential_user;

ALTER TABLE credential
ADD CONSTRAINT fk_credential_user
  FOREIGN KEY (id_user) REFERENCES "user"(id);
```

---

### Problema 3: Falta Validación UNIQUE en Documento

```
user.document_number ← Permite duplicados (riesgo de fraude)
```

**Solución Inmediata**:
```sql
ALTER TABLE "user" 
ADD CONSTRAINT uq_document_number UNIQUE (document_number);
```

---

## 📖 Documentación

### Empeza aquí 👇

1. **[📋 Índice Completo](README.md)**  
   Navegación a toda la documentación

2. **[🏗️ Visión General](arquitectura/01-vision-general.md)**  
   Qué es FaceLit, arquitectura, estado

3. **[📊 Esquemas](arquitectura/02-schemas.md)**  
   Cómo está organizada la BD

4. **[📈 Roadmap](planes/01-roadmap.md)**  
   Plan de desarrollo (5 fases)

5. **[✅ Validación](validacion/02-estrategia-validacion.md)**  
   Cómo se validan los datos

### Documentación Detallada

- [Modelo Entidad-Relación](datos/01-modelo-entidad-relacion.md) - Relaciones entre tablas
- [Tablas Detallado](datos/02-tablas.md) - Definición SQL completa
- [Fases Detalle](planes/02-fases-detalle.md) - Detalles técnicos de cada fase
- [Reglas de Integridad](validacion/01-reglas-integridad.md) - Validaciones

---

## 🛠️ Stack Tecnológico

| Componente | Tecnología | Versión |
|-----------|-----------|---------|
| **Base de Datos** | PostgreSQL | 16 Alpine |
| **Versionado** | Liquibase | 5.0.2 |
| **Contenedor** | Docker | Compose |
| **Extensión** | uuid-ossp | Nativa |

---

## 🚀 Levantamiento Local

### Requisitos
- Docker & Docker Compose
- Git

### Pasos

1. **Clonar repositorio**
   ```bash
   git clone <repo-url>
   cd FaceLit_db
   ```

2. **Crear archivo .env** (opcional)
   ```bash
   cp liquibase.properties.example liquibase.properties
   ```

3. **Levantar PostgreSQL**
   ```bash
   docker-compose up -d postgres
   ```

4. **Verificar que está corriendo**
   ```bash
   docker-compose ps
   ```

5. **Conectarse a la BD**
   ```bash
   # Usar DBeaver, pgAdmin o línea de comandos
   psql -h localhost -p 5439 -U facelit_user -d facelit
   ```

6. **Ejecutar migraciones** (próximamente automatizado)
   ```bash
   docker-compose up liquibase
   ```

---

## 📋 Próximos Pasos Inmediatos

### URGENTES (Semana 1)

- [ ] Corregir problemas críticos en credential (3 fixes)
- [ ] Ejecutar tests de integridad
- [ ] Agregar datos de prueba

### CORTO PLAZO (Semana 2-3)

- [ ] Agregar campos de auditoría (created_at, updated_at)
- [ ] Implementar triggers de auditoría
- [ ] Diseñar tablas de academic schema

### MEDIO PLAZO (Semana 4-6)

- [ ] Implementar FASE 2 (Académico)
- [ ] Validar relaciones FK
- [ ] Agregar índices de performance

---

## 📞 Búsqueda Rápida

### ¿Dónde está el código de...?

| Busco | Archivo |
|-------|---------|
| Definición tabla `user` | `01_ddl/03_tables/001_user.sql` |
| Definición tabla `credential` | `01_ddl/03_tables/002_credential.sql` |
| Extensión UUID | `01_ddl/00_extensions/001_enable_uuid_extension.sql` |
| Docker config | `docker-compose.yml` |
| Changelog maestro | `changelog-master.yaml` |

### ¿Dónde está la documentación de...?

| Busco | Archivo |
|-------|---------|
| Propósito general | `docs/arquitectura/01-vision-general.md` |
| Esquemas | `docs/arquitectura/02-schemas.md` |
| Tabla específica | `docs/datos/02-tablas.md` |
| Relaciones | `docs/datos/01-modelo-entidad-relacion.md` |
| Roadmap | `docs/planes/01-roadmap.md` |
| Validación | `docs/validacion/02-estrategia-validacion.md` |

---

## ⚙️ Configuración

### Variables de Entorno (docker-compose.yml)

```yaml
POSTGRES_DB: facelit
POSTGRES_USER: facelit_user
POSTGRES_PASSWORD: facelit_password
POSTGRES_PORT: 5439
```

**Cambiar** en `.env` o `docker-compose.yml`

### Health Check

La BD tiene health check automático cada 5 segundos. Liquibase espera que esté "healthy" antes de ejecutar.

---

## 🔄 Ciclo de Desarrollo

1. **Crear SQL** en `01_ddl/03_tables/XXX_description.sql`
2. **Registrar** en `01_ddl/03_tables/changelog.yaml`
3. **Crear rollback** en `05_rollbacks/01_ddl/03_tables/XXX_description.rollback.sql`
4. **Registrar rollback** en changelog
5. **Teslear** con Docker
6. **Documentar** cambios en `docs/`
7. **Commit** a Git

---

## ✨ Principios Clave

### 1. Segregación por Responsabilidad

```
DDL = Estructura (schemas, tablas)
DML = Datos (inserts, updates)
DCL = Permisos (roles, grants)
TCL = Transacciones (excepciones)
```

No mezclar en la misma carpeta.

### 2. Versionado Explícito

Cada cambio está en Git y Liquibase. Nada manual.

### 3. Rollback de Precisión

Cada migración puede revertirse sin ambigüedad.

### 4. Infraestructura como Código

Todo (BD, permisos, datos) está en código.

### 5. Auditoría Completa

Se puede rastrear quién hizo qué y cuándo.

---

## 🆘 Ayuda

### Error: `column "id_user" does not exist`

**Causa**: FK referencia inválida en credential  
**Solución**: Ver sección "Problemas Críticos" arriba

### Error: `duplicate key violates unique constraint`

**Causa**: Email o documento duplicado  
**Solución**: Verificar datos únicos antes de insertar

### Error: `type error on insert`

**Causa**: Tipo de dato inconsistente  
**Solución**: Verificar que id_user sea UUID

---

## 📅 Timeline

| Fase | Contenido | ETA | Estado |
|------|-----------|-----|--------|
| 1 | Estructura base + 2 tablas | Semana 1-2 | 🔄 90% |
| 2 | Académico (4 nuevas tablas) | Semana 3-4 | ⏳ Por hacer |
| 3 | Asistencias + Facial (4 tablas) | Semana 5-6 | ⏳ Por hacer |
| 4 | Seguridad + Auditoría | Semana 7-8 | ⏳ Por hacer |
| 5 | Reportes + Optimización | Semana 9+ | ⏳ Por hacer |

---

**Última Actualización**: 4 de Mayo de 2026  
**Versión**: 1.0  
**¿Preguntas?** Consulta el [Índice Completo](README.md)

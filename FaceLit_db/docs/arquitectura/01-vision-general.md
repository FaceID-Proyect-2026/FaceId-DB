# Visión General de la Arquitectura

## Propósito del Sistema

**FaceLit** es un sistema automatizado de control de asistencia mediante reconocimiento facial para el SENA.

- **Reemplaza**: Registro manual de asistencia (listas en Excel)
- **Automatiza**: Identificación de aprendices mediante análisis facial
- **Registra**: Hora exacta de ingreso/salida y clasificación de estado
- **Genera**: Reportes para instructores y administradores

---

## Arquitectura General

### Capas del Sistema

```
┌─────────────────────────────────────────┐
│   Capa de Presentación (Reportes)       │
├─────────────────────────────────────────┤
│   Capa de Negocio (Validaciones)        │
├─────────────────────────────────────────┤
│   Capa de Datos (PostgreSQL + Liquibase)│
├─────────────────────────────────────────┤
│   Capa de Integración (Raspberry Pi)    │
└─────────────────────────────────────────┘
```

### Tecnología Base

| Componente | Tecnología | Versión |
|-----------|-----------|---------|
| **Motor BD** | PostgreSQL | 16 Alpine |
| **Versionado** | Liquibase | 5.0.2 |
| **Orquestación** | Docker Compose | - |
| **Extensión** | uuid-ossp | Nativa PG |

---

## Organización del Repositorio

La base de datos está organizada por **responsabilidad SQL** (DDL, DML, DCL, TCL), no por tipo de objeto.

### Capas SQL

| Capa | Responsabilidad | Carpeta |
|------|-----------------|---------|
| **DDL** | Estructura (schemas, tablas, vistas, funciones) | `01_ddl/` |
| **DML** | Datos (inserts, updates, deletes, patches) | `02_dml/` |
| **DCL** | Acceso (roles, grants, políticas) | `03_dcl/` |
| **TCL** | Transacciones (bloques, recuperaciones) | `04_tcl/` |
| **Rollbacks** | Reversiones | `05_rollbacks/` |

---

## Estado Actual del Proyecto

### Fase: Inicial - Estructura Base

**Completado:**
- ✅ Extensión `uuid-ossp` habilitada
- ✅ 5 Schemas definidos
- ✅ 2 Tablas implementadas (user, credential)

**En Progreso:**
- 🔄 Tipos de datos personalizados
- 🔄 Vistas y vistas materializadas
- 🔄 Funciones y procedimientos
- 🔄 Triggers y auditoría
- 🔄 Índices de rendimiento

**Por Hacer:**
- ⏳ Roles y permisos (DCL)
- ⏳ Datos de referencia (DML)
- ⏳ Reportes y dashboards
- ⏳ Integración con APIs

---

## Principios Arquitectónicos

1. **Versionado Explícito**: Cada cambio está registrado en Liquibase
2. **Segregación por Responsabilidad**: DDL ≠ DML ≠ DCL
3. **Rollback de Precisión**: Cada migración puede revertirse sin ambigüedad
4. **Infraestructura como Código**: Toda la BD está en código Git
5. **Auditoría Completa**: Cambios rastreables desde el repositorio

---

## Relación con Módulos Funcionales

La BD soporta 11 módulos de negocio:

| RF | Módulo | Tablas | Estado |
|----|--------|--------|--------|
| RF-1 | Accesos | `user`, `credential` | ✅ Iniciado |
| RF-2 | Ambientes | Por diseñar | ⏳ Pendiente |
| RF-3 | Gestión Académica | Por diseñar | ⏳ Pendiente |
| RF-4 | Horarios | Por diseñar | ⏳ Pendiente |
| RF-5 | Reconocimiento Facial | Por diseñar | ⏳ Pendiente |
| RF-6 | Asistencias | Por diseñar | ⏳ Pendiente |
| RF-7 | Reportes | Vistas | ⏳ Pendiente |
| RF-8 | Notificaciones | Por diseñar | ⏳ Pendiente |
| RF-9 | Perfil | Por diseñar | ⏳ Pendiente |
| RF-10 | Administración | Por diseñar | ⏳ Pendiente |
| RF-11 | Bitácoras | Tablas de auditoría | ⏳ Pendiente |

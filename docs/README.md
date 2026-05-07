# Índice de Documentación - FaceLit DB

## 📋 Estructura de Documentación

Bienvenido a la documentación del proyecto **FaceLit DB**. Este índice te ayudará a navegar por toda la documentación.

---

## 🏗️ ARQUITECTURA

### [01 - Visión General](arquitectura/01-vision-general.md)
**¿Qué es FaceLit y cómo funciona?**

Contiene:
- Propósito del sistema
- Capas de arquitectura
- Tecnología base (PostgreSQL, Liquibase, Docker)
- Estado actual del proyecto
- Principios arquitectónicos
- Relación con 11 módulos funcionales

**Para leer si**: Eres nuevo en el proyecto y necesitas entender el contexto general.

---

### [02 - Esquemas (Schemas)](arquitectura/02-schemas.md)
**¿Cómo está organizada la base de datos?**

Contiene:
- 5 esquemas principales (security, academic, attendance, facial, audit)
- Propósito de cada schema
- Tablas planeadas por schema
- Relaciones entre esquemas
- Permisos por schema (planificado)
- Convenciones de nombres

**Para leer si**: Necesitas entender la organización de la BD o buscar una tabla específica.

---

## 📊 DATOS

### [01 - Modelo Entidad-Relación](datos/01-modelo-entidad-relacion.md)
**¿Cuáles son las relaciones entre tablas?**

Contiene:
- Diagrama MER de tablas actuales
- Definición de entidades (user, credential)
- Ciclo de vida de relaciones
- **⚠️ INCONSISTENCIAS DETECTADAS** (Problemas a corregir)
- Tablas futuras planeadas

**Para leer si**: Necesitas entender relaciones entre tablas o estás diseñando nuevas tablas.

---

### [02 - Especificación Detallada de Tablas](datos/02-tablas.md)
**¿Qué datos almacena cada tabla y cómo validarlos?**

Contiene:
- Definición SQL completa de cada tabla
- Diccionario de datos (columnas, tipos, restricciones)
- Estados permitidos (enumeraciones)
- Ejemplos de datos
- Casos de uso con queries
- **PROBLEMAS CONOCIDOS y soluciones**
- Mejoras planeadas
- Scripts de consulta útiles

**Para leer si**: Necesitas información detallada de una tabla, o estás escribiendo queries.

---

## 📈 PLANES

### [01 - Roadmap](planes/01-roadmap.md)
**¿Cuál es el plan de desarrollo del proyecto?**

Contiene:
- Timeline de 5 fases
- Estado actual de cada fase
- Deliverables por fase
- Criterios de salida
- Dependencias entre fases
- Riesgos y mitigaciones

**Para leer si**: Necesitas saber qué se está haciendo, cuándo, y en qué orden.

---

### [02 - Fases Detalle](planes/02-fases-detalle.md)
**¿Cuál es el plan detallado técnico de cada fase?**

Contiene:
- FASE 1: Estructura Base (actual) - Detallado
- FASE 1.5: Correcciones Críticas - Detallado
- FASE 2: Académico - Pre-planificación
- FASE 3: Asistencias - Pre-planificación
- FASE 4: Seguridad - Pre-planificación
- FASE 5: Reportes - Pre-planificación
- Tablas nuevas a crear (definiciones completas)
- Flujos de negocio (diagramas)
- Estimación de esfuerzo
- Criterios de aceptación

**Para leer si**: Eres developer y necesitas saber qué implementar en cada fase, con detalles técnicos.

---

## ✅ VALIDACIÓN

### [01 - Reglas de Integridad](validacion/01-reglas-integridad.md)
**¿Qué reglas garantizan la calidad de los datos?**

Contiene:
- Niveles de validación (7 capas)
- Validaciones implementadas actualmente
- Ciclos de vida de entidades (state machines)
- Invariantes de negocio
- Validaciones faltantes (críticas)
- Casos de uso: INSERT, UPDATE, DELETE
- Plan de testing
- Checklist pre-producción

**Para leer si**: Necesitas entender cómo se validan los datos en diferentes niveles.

---

### [02 - Estrategia de Validación](validacion/02-estrategia-validacion.md)
**¿Cómo implementamos validación end-to-end?**

Contiene:
- 7 capas de validación (desde BD hasta reportes)
- Detalle de cada validación por capa
- CHECK constraints (enumeraciones)
- UNIQUE constraints (campos únicos)
- Foreign Keys (integridad referencial)
- Validación en aplicación (passwords, emails, nombres)
- Lógica de negocio (workflow, ciclos de vida)
- Detección de anomalías
- Checklist de validación

**Para leer si**: Eres developer de backend/API y necesitas implementar validaciones.

---

## 🚨 PROBLEMAS CONOCIDOS (CRÍTICOS)

### En security.credential

1. **Tipo Inconsistente**
   - `credential.id_user` es `BIGINT`
   - Pero `user.id` es `UUID`
   - No se pueden relacionar
   - **Solución**: Cambiar a UUID
   - Ver: [datos/02-tablas.md#problemas-conocidos](datos/02-tablas.md#problemas-conocidos)

2. **Referencia Inválida**
   - FK apunta a `user.id_user`
   - Pero la tabla `user` no tiene esa columna
   - **Solución**: Cambiar a `user.id`
   - Ver: [datos/01-modelo-entidad-relacion.md#inconsistencias-detectadas](datos/01-modelo-entidad-relacion.md#inconsistencias-detectadas)

3. **Falta UNIQUE en document_number**
   - Permite documentos duplicados
   - **Solución**: Agregar constraint UNIQUE
   - Ver: [validacion/02-estrategia-validacion.md#capa-3-restricciones](validacion/02-estrategia-validacion.md#capa-3-restricciones)

### Acción Inmediata Necesaria

```sql
-- 1. Corregir tipo
ALTER TABLE credential ALTER COLUMN id_user TYPE UUID;

-- 2. Corregir FK
ALTER TABLE credential DROP CONSTRAINT fk_credential_user;
ALTER TABLE credential ADD CONSTRAINT fk_credential_user
  FOREIGN KEY (id_user) REFERENCES "user"(id);

-- 3. Agregar UNIQUE en documento
ALTER TABLE "user" ADD CONSTRAINT uq_document_number UNIQUE (document_number);
```

Crear archivo de migración: `01_ddl/03_tables/003_fix_critical_issues.sql`

---

## 🔍 Guía Rápida: Encontrar lo que Necesitas

### Busco: Información General
→ Lee primero [Visión General](arquitectura/01-vision-general.md)

### Busco: Una tabla específica
→ Ve a [Esquemas](arquitectura/02-schemas.md) para encontrar en qué schema está
→ Luego ve a [Tablas Detallado](datos/02-tablas.md) para información completa

### Busco: Relaciones entre tablas
→ Ve a [Modelo Entidad-Relación](datos/01-modelo-entidad-relacion.md)

### Busco: Qué necesito implementar
→ Ve a [Roadmap](planes/01-roadmap.md) para la fase general
→ Luego ve a [Fases Detalle](planes/02-fases-detalle.md) para detalles técnicos

### Busco: Cómo validar datos
→ Ve a [Reglas de Integridad](validacion/01-reglas-integridad.md)
→ O [Estrategia de Validación](validacion/02-estrategia-validacion.md) para implementación

### Busco: Solucionar un problema
→ Busca en [Problemas Conocidos](datos/02-tablas.md#problemas-conocidos)
→ O [Inconsistencias Detectadas](datos/01-modelo-entidad-relacion.md#inconsistencias-detectadas)

### Busco: Queries de ejemplo
→ Ve a [Tablas Detallado](datos/02-tablas.md#scripts-de-consulta-útiles)

---

## 📝 Actualización de Documentación

Esta documentación se actualiza cuando:

1. ✅ Nueva tabla es creada (agregar a [Esquemas](arquitectura/02-schemas.md) y [Fases Detalle](planes/02-fases-detalle.md))
2. ✅ Cambio estructural en BD (actualizar [MER](datos/01-modelo-entidad-relacion.md))
3. ✅ Nueva regla de validación (actualizar [Validación](validacion/))
4. ✅ Nueva fase completada (actualizar [Roadmap](planes/01-roadmap.md))

---

## 🎯 Estado del Proyecto

### Fase Actual: 1 - Estructura Base (90% completado)

**Completado** ✅
- 5 Schemas creados
- 2 Tablas implementadas (user, credential)
- Docker + Liquibase configurado
- Documentación inicial completa

**En Revisión** 🔄
- Correcciones críticas de integridad
- Mejoras de campos (timestamps)

**Próximo**: Fase 2 (Académico) - ETA: Semana 3-4

---

## 📞 Contacto

- **Repositorio**: FaceLit_db (local)
- **Base de Datos**: PostgreSQL 16 Alpine
- **Versionado**: Liquibase 5.0.2

---

## 📚 Referencias Externas

- [PostgreSQL 16 Docs](https://www.postgresql.org/docs/16/)
- [Liquibase Documentation](https://docs.liquibase.com/)
- [Docker Compose Reference](https://docs.docker.com/compose/compose-file/)
- [UUID en PostgreSQL](https://www.postgresql.org/docs/16/uuid-ossp.html)

---

**Última Actualización**: 4 de Mayo de 2026  
**Versión de Documentación**: 1.0 (Inicial)  
**Estado**: 📝 En Desarrollo

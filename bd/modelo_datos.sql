CREATE DATABASE FaceId;
USE FaceId;

/* =========================================================
   MODULO AUTH / SEGURIDAD - FACELIT
   ACTUALIZADO CON AUDITORIA BASE
========================================================= */


/* =========================================================
   TABLAS SEGURIDAD 
========================================================= */

CREATE TABLE Tipo_Documento (
    id_tipo_documento UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    nombre VARCHAR(100) NOT NULL,

    abreviacion VARCHAR(20) NOT NULL UNIQUE,

    /* AUDITORIA */
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    created_by BIGINT NULL,
    updated_by BIGINT NULL,
    deleted_at DATETIME NULL,
    deleted_by BIGINT NULL
);


/* =========================================================
   USUARIO
========================================================= */

CREATE TABLE Usuario (
    id_Usuario UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    nombreUsuario VARCHAR(100) NOT NULL,

    apellido VARCHAR(100) NOT NULL,

    fechaNacimiento DATE NOT NULL,

    estadoCuenta VARCHAR(20)
        CHECK (estadoCuenta IN ('ACTIVA','INACTIVA')),

    numero_documento VARCHAR(50) NOT NULL,

    id_tipo_documento UNIQUEIDENTIFIER NOT NULL,

    FOREIGN KEY (id_tipo_documento)
        REFERENCES Tipo_Documento(id_tipo_documento)

    /* AUDITORIA */
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    created_by BIGINT NULL,
    updated_by BIGINT NULL,
    deleted_at DATETIME NULL,
    deleted_by BIGINT NULL
);

/* =========================================================
   CREDENCIAL
========================================================= */

CREATE TABLE Credencial (
    id_Credencial UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    id_Usuario UNIQUEIDENTIFIER NOT NULL,

    correo VARCHAR(150) UNIQUE NOT NULL,

    contrasenaHash VARCHAR(255) NOT NULL,

    estado VARCHAR(20)
        CHECK (estado IN ('ACTIVO','INACTIVO')),

    intentosFallidos INT DEFAULT 0,

    FOREIGN KEY (id_Usuario)
        REFERENCES Usuario(id_Usuario),

    /* AUDITORIA */
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    created_by BIGINT NULL,
    updated_by BIGINT NULL,
    deleted_at DATETIME NULL,
    deleted_by BIGINT NULL
);


/* =========================================================
   EMAIL VERIFICACION
========================================================= */

CREATE TABLE EmailVerificacion (
    id_EmailVerificacion UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    id_Usuario UNIQUEIDENTIFIER NOT NULL,

    code VARCHAR(6) NOT NULL,

    expires_at TIMESTAMP NOT NULL,

    used BIT DEFAULT 0,

    FOREIGN KEY (id_Usuario)
        REFERENCES Usuario(id_Usuario),

    /* AUDITORIA */
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    created_by BIGINT NULL,
    updated_by BIGINT NULL,
    deleted_at DATETIME NULL,
    deleted_by BIGINT NULL
);


/* =========================================================
   RECUPERACION CONTRASEÑA
========================================================= */

CREATE TABLE RecuperacionContrasena (
    id_RecuperacionContrasena UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    id_Usuario UNIQUEIDENTIFIER NOT NULL,

    token VARCHAR(255) NOT NULL,

    fechaSolicitud DATETIME DEFAULT GETDATE(),

    fechaExpiracion DATETIME NOT NULL,

    usado BIT DEFAULT 0,

    estado VARCHAR(20)
        CHECK (estado IN ('ACTIVO','INACTIVO')),

    FOREIGN KEY (id_Usuario)
        REFERENCES Usuario(id_Usuario),

    /* AUDITORIA */
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    created_by BIGINT NULL,
    updated_by BIGINT NULL,
    deleted_at DATETIME NULL,
    deleted_by BIGINT NULL
);


/* =========================================================
   SESION USUARIO
========================================================= */

CREATE TABLE SesionUsuario (
    id_SesionUsuario UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    id_Usuario UNIQUEIDENTIFIER NOT NULL,

    fechaInicio DATETIME DEFAULT GETDATE(),

    fechaFin DATETIME NULL,

    ipOrigen VARCHAR(50),

    estadoSesion VARCHAR(20)
        CHECK (estadoSesion IN ('ACTIVO','INACTIVO')),

    FOREIGN KEY (id_Usuario)
        REFERENCES Usuario(id_Usuario),

    /* AUDITORIA */
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    created_by BIGINT NULL,
    updated_by BIGINT NULL,
    deleted_at DATETIME NULL,
    deleted_by BIGINT NULL
);


/* =========================================================
   CONFIGURACION USUARIO
========================================================= */

CREATE TABLE ConfiguracionUsuario (
    id_ConfiguracionUsuario UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    id_Usuario UNIQUEIDENTIFIER NOT NULL,

    nombreConfiguracion VARCHAR(100),

    descripcion VARCHAR(255),

    notificacionesActivas BIT DEFAULT 1,

    modoOscuro BIT DEFAULT 0,

    fechaActualizacion DATETIME DEFAULT GETDATE(),

    idioma VARCHAR(20)
        CHECK (idioma IN ('ES','EN','ZH','HI')),

    temaDashboard VARCHAR(50),

    colorPrimario VARCHAR(50),

    colorSecundario VARCHAR(50),

    FOREIGN KEY (id_Usuario)
        REFERENCES Usuario(id_Usuario),

    /* AUDITORIA */
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    created_by BIGINT NULL,
    updated_by BIGINT NULL,
    deleted_at DATETIME NULL,
    deleted_by BIGINT NULL
);


/* =========================
   DOMINIO ROLES Y PERMISOS
========================= */

CREATE TABLE Rol (
    id_Rol UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    nombreRol VARCHAR(20)
        CHECK (nombreRol IN ('APRENDIZ','INSTRUCTOR','ADMINISTRADOR'))
);

CREATE TABLE Permiso (
    id_Permiso UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    nombrePermiso VARCHAR(100),

    descripcion VARCHAR(255)
);

CREATE TABLE Usuario_Rol (
    id_Usuario UNIQUEIDENTIFIER,
    id_Rol UNIQUEIDENTIFIER,

    fechaAsignacion DATE,

    PRIMARY KEY (id_Usuario, id_Rol),

    FOREIGN KEY (id_Usuario)
        REFERENCES Usuario(id_Usuario),

    FOREIGN KEY (id_Rol)
        REFERENCES Rol(id_Rol)
);

CREATE TABLE Rol_Permiso (
    id_Rol UNIQUEIDENTIFIER,
    id_Permiso UNIQUEIDENTIFIER,

    fechaAsignacion DATE,

    PRIMARY KEY (id_Rol, id_Permiso),

    FOREIGN KEY (id_Rol)
        REFERENCES Rol(id_Rol),

    FOREIGN KEY (id_Permiso)
        REFERENCES Permiso(id_Permiso)
);


/* =========================
   DOMINIO GESTION ACADEMICA
========================= */

CREATE TABLE Programa (
    id_Programa UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    nombrePrograma VARCHAR(100),

    codigo VARCHAR(50),

    nivel VARCHAR(20)
        CHECK (nivel IN ('TECNICO','TECNOLOGO')),

    estado VARCHAR(20)
        CHECK (estado IN ('ACTIVO','INACTIVO'))
);

CREATE TABLE Ficha (
    id_Ficha UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    id_Programa UNIQUEIDENTIFIER,

    codigoFicha VARCHAR(50),

    nombreFicha VARCHAR(100),

    estado VARCHAR(20)
        CHECK (estado IN ('ACTIVO','INACTIVO')),

    jornada VARCHAR(50),

    FOREIGN KEY (id_Programa)
        REFERENCES Programa(id_Programa)
);

CREATE TABLE Ficha_Usuario (
    id_Ficha UNIQUEIDENTIFIER,

    id_Usuario UNIQUEIDENTIFIER,

    fechaAsignacion DATE NOT NULL,

    estado VARCHAR(20)
        CHECK (estado IN ('ACTIVO','INACTIVO')),

    PRIMARY KEY (id_Ficha, id_Usuario),

    FOREIGN KEY (id_Ficha)
        REFERENCES Ficha(id_Ficha),

    FOREIGN KEY (id_Usuario)
        REFERENCES Usuario(id_Usuario)
);


/* =========================
   DOMINIO GESTION DE AMBIENTES
========================= */

CREATE TABLE Ambiente (
    id_Ambiente UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    codigoAmbiente VARCHAR(50),

    nombreAmbiente VARCHAR(100),

    capacidad INT,

    estado VARCHAR(20)
        CHECK (estado IN ('ACTIVO','INACTIVO'))
);

CREATE TABLE Ficha_Ambiente (
    id_Ficha UNIQUEIDENTIFIER,

    id_Ambiente UNIQUEIDENTIFIER,

    fechaAsignacion DATE,

    activa VARCHAR(10),

    PRIMARY KEY (id_Ficha, id_Ambiente),

    FOREIGN KEY (id_Ficha)
        REFERENCES Ficha(id_Ficha),

    FOREIGN KEY (id_Ambiente)
        REFERENCES Ambiente(id_Ambiente)
);

CREATE TABLE RestriccionAmbiente (
    id_Restriccion UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    id_Ambiente UNIQUEIDENTIFIER,

    tipoRestriccion VARCHAR(20)
        CHECK (tipoRestriccion IN ('TEMPORAL','INDEFINIDA')),

    fechaInicio DATE,

    fechaFin DATE,

    motivo VARCHAR(255),

    FOREIGN KEY (id_Ambiente)
        REFERENCES Ambiente(id_Ambiente)
);

CREATE TABLE ExcepcionAmbiente (
    id_Excepcion UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    id_Ambiente UNIQUEIDENTIFIER,

    id_Ficha UNIQUEIDENTIFIER,

    fechaExcepcion DATE,

    motivo VARCHAR(255),

    descripcion TEXT,

    FOREIGN KEY (id_Ambiente)
        REFERENCES Ambiente(id_Ambiente),

    FOREIGN KEY (id_Ficha)
        REFERENCES Ficha(id_Ficha)
);


/* =========================
   DOMINIOGESTION DE HORARIOS
========================= */

CREATE TABLE Horario (
    id_Horario UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    id_Ficha UNIQUEIDENTIFIER,

    diaSemana VARCHAR(20),

    horaInicio TIME,

    horaFin TIME,

    estado VARCHAR(20)
        CHECK (estado IN ('ACTIVO','INACTIVO')),

    fechaCreacion DATE,

    FOREIGN KEY (id_Ficha)
        REFERENCES Ficha(id_Ficha)
);

CREATE TABLE Horario_Instructor (
    id_HorarioInstructor UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    id_Horario UNIQUEIDENTIFIER,

    id_Usuario UNIQUEIDENTIFIER,

    activo VARCHAR(20),

    FOREIGN KEY (id_Horario)
        REFERENCES Horario(id_Horario),

    FOREIGN KEY (id_Usuario)
        REFERENCES Usuario(id_Usuario)
);

CREATE TABLE Horario_Ambiente (
    id_Horario UNIQUEIDENTIFIER,

    id_Ambiente UNIQUEIDENTIFIER,

    PRIMARY KEY (id_Horario, id_Ambiente),

    FOREIGN KEY (id_Horario)
        REFERENCES Horario(id_Horario),

    FOREIGN KEY (id_Ambiente)
        REFERENCES Ambiente(id_Ambiente)
);

CREATE TABLE ExcepcionHorario (
    id_ExcepcionHorario UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    id_Horario UNIQUEIDENTIFIER,

    fecha DATE,

    motivo VARCHAR(255),

    estado VARCHAR(20)
        CHECK (estado IN ('ACTIVO','INACTIVO')),

    fechaRegistro DATE,

    FOREIGN KEY (id_Horario)
        REFERENCES Horario(id_Horario)
);


/* =========================
   DOMINIO RECONOCIMIENTO FACIAL
========================= */

CREATE TABLE Dispositivo (
    id_Dispositivo UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    codigoDispositivo VARCHAR(50),

    ubicacion VARCHAR(100),

    estado VARCHAR(20)
        CHECK (estado IN ('ACTIVO','INACTIVO')),

    ipOrigen VARCHAR(50)
);

CREATE TABLE RostroUsuario (
    id_RostroUsuario UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    id_Usuario UNIQUEIDENTIFIER,

    vectorBiometrico VARBINARY(MAX),

    fechaRegistro DATETIME,

    estado VARCHAR(20)
        CHECK (estado IN ('ACTIVO','PENDIENTE','INACTIVO')),

    FOREIGN KEY (id_Usuario)
        REFERENCES Usuario(id_Usuario)
);

CREATE TABLE EventoFacial (
    id_EventoFacial UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),
    id_Usuario UNIQUEIDENTIFIER NULL,
    id_Ambiente UNIQUEIDENTIFIER,
    id_Ficha UNIQUEIDENTIFIER NULL,
    id_Dispositivo UNIQUEIDENTIFIER,
    fechaHora DATETIME,
    tipoEvento VARCHAR(20)
        CHECK (tipoEvento IN ('ENTRADA','DESCANSO','SALIDA')),

    resultado VARCHAR(20)
        CHECK (resultado IN ('RECONOCIDO','NO RECONOCIDO')),

    estadoEnvio VARCHAR(20)
        CHECK (estadoEnvio IN ('PENDIENTE','ENVIADO')),

    origen VARCHAR(20)
        CHECK (origen IN ('ONLINE','OFFLINE')),

    FOREIGN KEY (id_Usuario)
        REFERENCES Usuario(id_Usuario),

    FOREIGN KEY (id_Ambiente)
        REFERENCES Ambiente(id_Ambiente),

    FOREIGN KEY (id_Ficha)
        REFERENCES Ficha(id_Ficha),

    FOREIGN KEY (id_Dispositivo)
        REFERENCES Dispositivo(id_Dispositivo)
);

CREATE TABLE BitacoraBiometrica (
    id_Bitacora UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),
    id_Evento UNIQUEIDENTIFIER,

    descripcion TEXT,

    fecha DATETIME,

    FOREIGN KEY (id_Evento)
        REFERENCES EventoFacial(id_EventoFacial)
);


/* =========================
   DOMINIO NOTIFICACIONES
========================= */

CREATE TABLE Notificacion (
    id_Notificacion UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    id_Usuario UNIQUEIDENTIFIER,

    id_Evento UNIQUEIDENTIFIER NULL,

    tipo VARCHAR(20)
        CHECK (tipo IN ('ALERTA','AVISO','RECORDATORIO')),

    titulo VARCHAR(100),

    mensaje VARCHAR(255),

    fechaHora DATETIME,

    estado VARCHAR(20)
        CHECK (estado IN ('LEIDA','NO LEIDA')),

    canal VARCHAR(20)
        CHECK (canal IN ('INTERNA','EMAIL','AMBOS')),

    origenEvento VARCHAR(20)
        CHECK (origenEvento IN ('ASISTENCIA','ANOMALIA','HORARIO','SISTEMA')),

    prioridad VARCHAR(20),

    FOREIGN KEY (id_Usuario)
        REFERENCES Usuario(id_Usuario),

    FOREIGN KEY (id_Evento)
        REFERENCES EventoFacial(id_EventoFacial)
);

CREATE TABLE EnvioCorreo (
    id_EnvioCorreo UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    id_Notificacion UNIQUEIDENTIFIER,

    correoDestino VARCHAR(150),

    fechaEnvio DATETIME,

    estadoEnvio VARCHAR(20)
        CHECK (estadoEnvio IN ('ENVIADO','PENDIENTE','ERROR')),

    intentos INT,

    FOREIGN KEY (id_Notificacion)
        REFERENCES Notificacion(id_Notificacion)
);


/* =========================
   DOMINIO GESTION LEGAL
========================= */

/* =========================================================
   ACEPTACION TERMINOS
========================================================= */

CREATE TABLE AceptacionTermino (
    id_Aceptacion UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    id_Usuario UNIQUEIDENTIFIER NOT NULL,

    aceptado BIT NOT NULL,
s
    ip_origen VARCHAR(50),

    FOREIGN KEY (id_Usuario)
        REFERENCES Usuario(id_Usuario),

    /* AUDITORIA */
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    created_by BIGINT NULL,
    updated_by BIGINT NULL,
    deleted_at DATETIME NULL,
    deleted_by BIGINT NULL
);


/* =========================================================
   ACUDIENTE
========================================================= */

CREATE TABLE Acudiente (
    id_Acudiente UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    nombreCompleto VARCHAR(150) NOT NULL,

    documentoIdentidad VARCHAR(50) NOT NULL,

    correo_Acudiente VARCHAR(150) NOT NULL,

    /* AUDITORIA */
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    created_by BIGINT NULL,
    updated_by BIGINT NULL,
    deleted_at DATETIME NULL,
    deleted_by BIGINT NULL
);


/* =========================================================
   CONSENTIMIENTO
========================================================= */

CREATE TABLE Consentimiento (
    id_Consentimiento UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    id_Usuario UNIQUEIDENTIFIER NOT NULL,

    id_Acudiente UNIQUEIDENTIFIER NULL,

    estadoConsentimiento VARCHAR(20)
        CHECK (estadoConsentimiento IN
        ('PENDIENTE','ACEPTADO','RECHAZADO')),

    fechaSolicitud TIMESTAMP NOT NULL,

    fechaRespuesta TIMESTAMP NULL,

    FOREIGN KEY (id_Usuario)
        REFERENCES Usuario(id_Usuario),

    FOREIGN KEY (id_Acudiente)
        REFERENCES Acudiente(id_Acudiente),

    /* AUDITORIA */
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    created_by BIGINT NULL,
    updated_by BIGINT NULL,
    deleted_at DATETIME NULL,
    deleted_by BIGINT NULL
);


/* =========================================================
   VERIFICACION CONSENTIMIENTO
========================================================= */

CREATE TABLE Verificacion_Consentimiento (
    id_VerificacionConsentimiento UNIQUEIDENTIFIER
        PRIMARY KEY DEFAULT NEWID(),

    id_Consentimiento UNIQUEIDENTIFIER NOT NULL,

    token VARCHAR(255) NOT NULL,

    fechaExpiracion TIMESTAMP NOT NULL,

    usado BIT DEFAULT 0,

    FOREIGN KEY (id_Consentimiento)
        REFERENCES Consentimiento(id_Consentimiento),

    /* AUDITORIA */
    created_at DATETIME DEFAULT GETDATE(),
    updated_at DATETIME DEFAULT GETDATE(),
    created_by BIGINT NULL,
    updated_by BIGINT NULL,
    deleted_at DATETIME NULL,
    deleted_by BIGINT NULL
);




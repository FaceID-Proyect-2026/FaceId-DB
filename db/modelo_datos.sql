CREATE DATABASE FaceId;
USE FaceId;

/* =========================
   USUARIO Y SEGURIDAD
========================= */

CREATE TABLE Usuario (
    id_Usuario INT IDENTITY PRIMARY KEY,
    nombreUsuario VARCHAR(100) NOT NULL,
    apellido VARCHAR(100) NOT NULL,
    fechaNacimiento DATE,
    estadoCuenta VARCHAR(20) CHECK (estadoCuenta IN ('ACTIVA','INACTIVA')),
    fechaRegistro DATETIME DEFAULT GETDATE()
);

CREATE TABLE Credencial (
    id_Credencial INT IDENTITY PRIMARY KEY,
    id_Usuario INT NOT NULL,
    correo VARCHAR(150) UNIQUE NOT NULL,
    contrasenaHash VARCHAR(255) NOT NULL,
    estado VARCHAR(20) CHECK (estado IN ('ACTIVO','INACTIVO')),
    intentosFallidos INT DEFAULT 0,
    fechaCreacion DATETIME DEFAULT GETDATE(),
    ultimaModificacion DATETIME,
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario)
);

CREATE TABLE Politicas_Contrasenas (
    id_politica INT IDENTITY PRIMARY KEY,
    minLongitud INT,
    maxLongitud INT,
    requiereMayusculas BIT,
    requiereNumeros BIT,
    requiereSimbolos BIT,
    caducidadDias INT
);

CREATE TABLE RecuperacionContrasena (
    id_RecuperacionContrasena INT IDENTITY PRIMARY KEY,
    id_Usuario INT NOT NULL,
    token VARCHAR(255),
    fechaSolicitud DATETIME,
    fechaExpiracion DATETIME,
    usado BIT,
    estado VARCHAR(20) CHECK (estado IN ('ACTIVO','INACTIVO'))
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario)
);

CREATE TABLE SesionUsuario (
    id_SesionUsuario INT IDENTITY PRIMARY KEY,
    id_Usuario INT NOT NULL,
    fechaInicio DATETIME,
    fechaFin DATETIME,
    ipOrigen VARCHAR(50),
    estadoSesion VARCHAR(20) CHECK (estadoSesion IN ('ACTIVO','INACTIVO'))
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario)
);

CREATE TABLE Auditoria (
    id_Auditoria INT IDENTITY PRIMARY KEY,
    id_Usuario INT,
    accion VARCHAR(100),
    fecha DATETIME,
    descripcion VARCHAR(255),
    ipOrigen VARCHAR(50),
    aplicacion VARCHAR(100),
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario)
);

CREATE TABLE Log_Errores (
    id_Error INT IDENTITY PRIMARY KEY,
    id_Usuario INT,
    fecha DATETIME,
    tipoError VARCHAR(100),
    descripcion VARCHAR(255),
    ipOrigen VARCHAR(50),
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario)
);

CREATE TABLE BitacoraSistema (
    id_BitacoraSistema INT IDENTITY PRIMARY KEY,
    id_Usuario INT,
    accion VARCHAR(100),
    modulo VARCHAR(100),
    descripcion TEXT,
    fechaHora DATETIME,
    ipOrigen VARCHAR(50),
    resultado VARCHAR(20) CHECK (resultado IN ('EXITOSO','FALLIDO')),
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario)
);

CREATE TABLE ConfiguracionUsuario (
    id_ConfiguracionUsuario INT IDENTITY PRIMARY KEY,
    id_Usuario INT NOT NULL,
    nombreConfiguracion VARCHAR(100),
    descripcion VARCHAR(255),
    notificacionesActivas BIT,
    modoOscuro BIT,
    fechaActualizacion DATETIME,
    idioma VARCHAR(20) CHECK (idioma IN ('ES','EN','ZH', 'HI')),
    temaDashboard VARCHAR(50),
    colorPrimario VARCHAR(50),
    colorSecundario VARCHAR(50),
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario)
);

/* =========================
   ROLES Y PERMISOS
========================= */

CREATE TABLE Rol (
    id_Rol INT IDENTITY PRIMARY KEY,
    nombreRol VARCHAR(20) CHECK (nombreRol IN ('APRENDIZ','INSTRUCTOR','ADMINISTRADOR'))
);

CREATE TABLE Permisos (
    id_Permiso INT IDENTITY PRIMARY KEY,
    nombrePermiso VARCHAR(100),
    descripcion VARCHAR(255)
);

CREATE TABLE Usuario_Rol (
    id_Usuario INT,
    id_Rol INT,
    fechaAsignacion DATE,
    PRIMARY KEY (id_Usuario, id_Rol),
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario),
    FOREIGN KEY (id_Rol) REFERENCES Rol(id_Rol)
);

CREATE TABLE Rol_Permiso (
    id_Rol INT,
    id_Permiso INT,
    fechaAsignacion DATE,
    PRIMARY KEY (id_Rol, id_Permiso),
    FOREIGN KEY (id_Rol) REFERENCES Rol(id_Rol),
    FOREIGN KEY (id_Permiso) REFERENCES Permisos(id_Permiso)
);

/* =========================
   GESTION ACADEMICA
========================= */

CREATE TABLE Programa (
    id_Programa INT IDENTITY PRIMARY KEY,
    nombrePrograma VARCHAR(100),
    codigo VARCHAR(50),
    nivel VARCHAR(20) CHECK (nivel IN ('TECNICO','TECNOLOGO')),
    estado VARCHAR(20) CHECK (estado IN ('ACTIVO','INACTIVO'))
);

CREATE TABLE Ficha (
    id_Ficha INT IDENTITY PRIMARY KEY,
    id_Programa INT,
    codigoFicha VARCHAR(50),
    nombreFicha VARCHAR(100),
    estado VARCHAR(20) CHECK (estado IN ('ACTIVO','INACTIVO')),
    jornada VARCHAR(50),
    FOREIGN KEY (id_Programa) REFERENCES Programa(id_Programa)
);

CREATE TABLE Ficha_Usuario (
    id_Ficha INT IDENTITY(1,1) PRIMARY KEY,
    id_Usuario INT NOT NULL,
    fechaAsignacion DATE NOT NULL,
    estado VARCHAR(20) CHECK (estado IN ('ACTIVO','INACTIVO')),
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario)
);

/* =========================
   GESTION DE AMBIENTES
========================= */

CREATE TABLE Ambiente (
    id_Ambiente INT IDENTITY PRIMARY KEY,
    codigoAmbiente VARCHAR(50),
    nombreAmbiente VARCHAR(100),
    capacidad INT,
    estado VARCHAR(20) CHECK (estado IN ('ACTIVO','INACTIVO'))
);

CREATE TABLE Ficha_Ambiente (
    id_Ficha INT,
    id_Ambiente INT,
    fechaAsignacion DATE,
    activa VARCHAR(10),
    PRIMARY KEY (id_Ficha, id_Ambiente),
    FOREIGN KEY (id_Ficha) REFERENCES Ficha(id_Ficha),
    FOREIGN KEY (id_Ambiente) REFERENCES Ambiente(id_Ambiente)
);

CREATE TABLE RestriccionAmbiente (
    id_Restriccion INT IDENTITY PRIMARY KEY,
    id_Ambiente INT,
    tipoRestriccion VARCHAR(20) CHECK (tipoRestriccion IN ('TEMPORAL','INDEFINIDA')),
    fechaInicio DATE,
    fechaFin DATE,
    motivo VARCHAR(255),
    FOREIGN KEY (id_Ambiente) REFERENCES Ambiente(id_Ambiente)
);

CREATE TABLE ExcepcionAmbiente (
    id_Excepcion INT IDENTITY PRIMARY KEY,
    id_Ambiente INT,
    id_Ficha INT,
    fechaExcepcion DATE,
    motivo VARCHAR(255),
    descripcion TEXT,
    FOREIGN KEY (id_Ambiente) REFERENCES Ambiente(id_Ambiente),
    FOREIGN KEY (id_Ficha) REFERENCES Ficha(id_Ficha)
);

/* =========================
   GESTION DE HORARIOS
========================= */

CREATE TABLE Horario (
    id_Horario INT IDENTITY PRIMARY KEY,
    id_Ficha INT,
    diaSemana VARCHAR(20),
    horaInicio TIME,
    horaFin TIME,
    estado VARCHAR(20) CHECK (estado IN ('ACTIVO','INACTIVO')),
    fechaCreacion DATE,
    FOREIGN KEY (id_Ficha) REFERENCES Ficha(id_Ficha)
);

CREATE TABLE Horario_Instructor (
    id_HorarioInstructor INT IDENTITY PRIMARY KEY,
    id_Horario INT,
    id_Usuario INT,
    activo VARCHAR,
    FOREIGN KEY (id_Horario) REFERENCES Horario(id_Horario),
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario)
);

CREATE TABLE Horario_Ambiente (
    id_Horario INT,
    id_Ambiente INT,
    PRIMARY KEY (id_Horario, id_Ambiente),
    FOREIGN KEY (id_Horario) REFERENCES Horario(id_Horario),
    FOREIGN KEY (id_Ambiente) REFERENCES Ambiente(id_Ambiente)
);

CREATE TABLE ExcepcionHorario (
    id_ExcepcionHorario INT IDENTITY PRIMARY KEY,
    id_Horario INT,
    fecha DATE,
    motivo VARCHAR(255),
    estado VARCHAR(20) CHECK (estado IN ('ACTIVO','INACTIVO')),
    fechaRegistro DATE,
    FOREIGN KEY (id_Horario) REFERENCES Horario(id_Horario)
);

/* =========================
   RECONOCIMIENTO FACIAL
========================= */

CREATE TABLE Dispositivo (
    id_Dispositivo INT IDENTITY PRIMARY KEY,
    codigoDispositivo VARCHAR(50),
    ubicacion VARCHAR(100),
    estado VARCHAR(20) CHECK (estado IN ('ACTIVO','INACTIVO')),
    ipOrigen VARCHAR(50)
);

CREATE TABLE RostroUsuario (
    id_RostroUsuario INT IDENTITY PRIMARY KEY,
    id_Usuario INT,
    vectorBiometrico VARBINARY(MAX),
    fechaRegistro DATETIME,
    estado VARCHAR(20) CHECK (estado IN ('ACTIVO','PENDIENTE','INACTIVO'))
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario)
);

CREATE TABLE EventoFacial (
    id_EventoFacial INT IDENTITY PRIMARY KEY,
    id_Usuario INT NULL,
    id_Ambiente INT,
    id_Ficha INT NULL,
    id_Dispositivo INT,
    fechaHora DATETIME,
    tipoEvento VARCHAR(20) CHECK (tipoEvento IN ('ENTRADA','DESCANSO','SALIDA')),
    resultado VARCHAR(20) CHECK (resultado IN ('RECONOCIDO','NO RECONOCIDO')),
    estadoEnvio VARCHAR(20) CHECK (estadoEnvio IN ('PENDIENTE','ENVIADO')),
    origen VARCHAR(20) CHECK (origen IN ('ONLINE','OFFLINE'))
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario),
    FOREIGN KEY (id_Ambiente) REFERENCES Ambiente(id_Ambiente),
    FOREIGN KEY (id_Ficha) REFERENCES Ficha(id_Ficha),
    FOREIGN KEY (id_Dispositivo) REFERENCES Dispositivo(id_Dispositivo)
);

CREATE TABLE BitacoraBiometrica (
    id_Bitacora INT IDENTITY PRIMARY KEY,
    id_Evento INT,
    descripcion TEXT,
    fecha DATETIME,
    FOREIGN KEY (id_Evento) REFERENCES EventoFacial(id_EventoFacial)
);

/* =========================
   NOTIFICACIONES
========================= */

CREATE TABLE Notificaciones (
    id_Notificacion INT IDENTITY PRIMARY KEY,
    id_Usuario INT,
    id_Evento INT NULL,
    tipo VARCHAR(20) CHECK (tipo IN ('ALERTA','AVISO','RECORDATORIO')),
    titulo VARCHAR(100),
    mensaje VARCHAR(255),
    fechaHora DATETIME,
    estado VARCHAR(20) CHECK (estado IN ('LEIDA','NO LEIDA')),
    canal VARCHAR(20) CHECK (canal IN ('INTERNA','EMAIL','AMBOS')),
    origenEvento VARCHAR(20) CHECK (estado IN ('ASISTENCIA','ANOMALIA','HORARIO', 'SISTEMA')),
    prioridad VARCHAR(20),
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario),
    FOREIGN KEY (id_Evento) REFERENCES EventoFacial(id_EventoFacial)
);

CREATE TABLE EnvioCorreo (
    id_EnvioCorreo INT IDENTITY PRIMARY KEY,
    id_Notificacion INT,
    correoDestino VARCHAR(150),
    fechaEnvio DATETIME,
    estadoEnvio VARCHAR(20) CHECK (estadoEnvio IN ('ENVIADO','PENDIENTE','ERROR')),
    intentos INT,
    FOREIGN KEY (id_Notificacion) REFERENCES Notificaciones(id_Notificacion)
);

/* =========================
   EXCUSAS
========================= */

CREATE TABLE Excusa (
    id_Excusa INT IDENTITY PRIMARY KEY,
    id_Usuario INT,
    fechaAusencia DATE,
    mensaje VARCHAR(255),
    archivoPDF VARCHAR(255),
    fechaEnvio DATETIME,
    estado VARCHAR(20) CHECK (estado IN ('PENDIENTE','APROVADA', 'RECHAZADA')),
    revisadoPor VARCHAR(100),
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario)
);

/* =========================
   GESTION LEGAL
========================= */
CREATE TABLE TerminosCondiciones (
    id_Terminos INT IDENTITY(1,1) PRIMARY KEY,
    tipo VARCHAR(50) NOT NULL,
    textoTerminos TEXT NOT NULL
);

CREATE TABLE AceptacionTerminos (
    id_Aceptacion INT IDENTITY(1,1) PRIMARY KEY,
    id_Usuario INT NOT NULL,
    id_Terminos INT NOT NULL,
    aceptado VARCHAR(10) NOT NULL,
    fechaAceptacion DATETIME NOT NULL,
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario),
    FOREIGN KEY (id_Terminos) REFERENCES TerminosCondiciones(id_Terminos)
);

CREATE TABLE Acudiente (
    id_Acudiente INT IDENTITY(1,1) PRIMARY KEY,
    nombreCompleto VARCHAR(150) NOT NULL,
    documentoIdentidad VARCHAR(50) NOT NULL
);

CREATE TABLE Consentimiento (
    id_Consentimiento INT IDENTITY(1,1) PRIMARY KEY,
    id_Usuario INT NOT NULL,
    id_Acudiente INT NULL,
    menorEdad BIT NOT NULL,
    consentimientoAdulto BIT NOT NULL,
    fechaAceptacion DATETIME NOT NULL,
    validadoAdmin BIT NOT NULL,
    FOREIGN KEY (id_Usuario) REFERENCES Usuario(id_Usuario),
    FOREIGN KEY (id_Acudiente) REFERENCES Acudiente(id_Acudiente)
);
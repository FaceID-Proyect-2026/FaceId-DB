CREATE TABLE environments.ambient (
    id_ambient UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
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
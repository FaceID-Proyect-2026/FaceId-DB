CREATE TABLE environment.environment (
    id_environment UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    environment_name VARCHAR(100),
    capacity INT,
    status VARCHAR(20),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE environment.chip_environment (
    id_chip_environment UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_chip UUID NOT NULL,
    id_environment UUID NOT NULL,
    assignment_date DATE NOT NULL,
    status VARCHAR(20),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE environment.record_environment (
    id_record_environment UUID NOT NULL PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_environment UUID NOT NULL,
    id_schedule UUID NOT NULL,
    assignment_date TIMESTAMPTZ NOT NULL,
    active VARCHAR(20),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ
);
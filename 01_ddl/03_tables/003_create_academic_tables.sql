CREATE TABLE academic.program (
    id_program UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    program_name VARCHAR(100) NOT NULL UNIQUE,
    state VARCHAR(20),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_program_state
        CHECK (state IN ('ACTIVE','INACTIVE'))
);

CREATE TABLE academic.chip (
    id_chip UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_program UUID NOT NULL,
    chip_code VARCHAR(50),
    chip_name VARCHAR(100),
    state VARCHAR(20),
    workingday VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_state_chip
        CHECK (state IN ('ACTIVE','INACTIVE'))
);

CREATE TABLE academic.user_chip (
    id_user_chip UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_user_app UUID NOT NULL,
    id_chip UUID NOT NULL,
    assignment_date DATE NOT NULL,
    state VARCHAR(20),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_state_user_chip
        CHECK (state IN ('ACTIVE','INACTIVE'))
);
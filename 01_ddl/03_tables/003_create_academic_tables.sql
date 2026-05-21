CREATE TABLE academic.program (
    id_program UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    program_name VARCHAR(100) NOT NULL UNIQUE,
    state VARCHAR(20),
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
    CONSTRAINT chk_state_chip
        CHECK (state IN ('ACTIVE','INACTIVE'))
);

CREATE TABLE academic.user_chip (
    id_user_chip UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_users UUID NOT NULL,
    assignment_date DATE NOT NULL,
    state VARCHAR(20),
    CONSTRAINT chk_state_user_chip
        CHECK (state IN ('ACTIVE','INACTIVE'))
);
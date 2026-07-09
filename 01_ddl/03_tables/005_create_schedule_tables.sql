CREATE TABLE schedule.schedule (
    id_schedule UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_chip UUID NOT NULL,
    day_of_week VARCHAR(20) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status VARCHAR(20) NOT NULL,
    creation_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_schedule_status
        CHECK (status IN ('ACTIVE','INACTIVE'))
);

CREATE TABLE schedule.schedule_instructor (
    id_schedule_instructor UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_schedule UUID NOT NULL,
    id_user_app UUID NOT NULL,
    status VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_schedule_instructor_status
        CHECK (status IN ('ACTIVE','INACTIVE'))
);

CREATE TABLE schedule.schedule_exception (
    id_schedule_exception UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_schedule UUID NOT NULL,
    id_environment UUID NOT NULL,
    exception_date DATE NOT NULL,
    reason VARCHAR(255),
    status VARCHAR(20) NOT NULL,
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_schedule_exception_status
        CHECK (status IN ('ACTIVE','INACTIVE'))
);
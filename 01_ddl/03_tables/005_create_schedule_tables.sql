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
    deleted_at TIMESTAMPTZ
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
    deleted_at TIMESTAMPTZ
);

CREATE TABLE schedule.schedule_exception (
    id_schedule_exception UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_schedule UUID NOT NULL,
    id_environment UUID,
    id_instructor_replacement UUID,
    exception_date DATE NOT NULL,
    end_date DATE,
    exception_type VARCHAR(30) NOT NULL DEFAULT 'ENVIRONMENT_CHANGE',
    reason VARCHAR(255),
    status VARCHAR(20) NOT NULL,
    registration_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,

    CONSTRAINT chk_schedule_exception_end_date
        CHECK (end_date IS NULL OR end_date >= exception_date)
);
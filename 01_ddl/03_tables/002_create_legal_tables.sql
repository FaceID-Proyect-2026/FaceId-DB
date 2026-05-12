CREATE TABLE legal.guardian (
    id_guardian UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name VARCHAR(150) NOT NULL,
    identity_document VARCHAR(50) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
);

CREATE TABLE legal.consent (
    id_consent UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_user UUID NOT NULL,
    id_guardian UUID NULL,
    minor BOOLEAN NOT NULL,
    adult_consent BOOLEAN NOT NULL,
    acceptance_date TIMESTAMPTZ NOT NULL,
    admin_validated BOOLEAN NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
);
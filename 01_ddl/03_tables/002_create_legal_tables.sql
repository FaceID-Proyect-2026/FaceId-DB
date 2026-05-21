-- GUARDIAN
CREATE TABLE legal.guardian (
    id_guardian UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    full_name VARCHAR(150) NOT NULL,
    identity_document VARCHAR(50) NOT NULL UNIQUE,
    guardian_email VARCHAR(255) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ
);

-- CONSENT
CREATE TABLE legal.consent (
    id_consent UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_users UUID NOT NULL,
    id_guardian UUID NULL,
    consent_status VARCHAR(20) NOT NULL,
    application_date TIMESTAMPTZ NOT NULL,
    response_date TIMESTAMPTZ NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_consent_status
        CHECK (consent_status IN ('PENDING','ACCEPTED','REJECTED'))
);

-- CONSENT VERIFICATION
CREATE TABLE legal.consent_verification (
    id_consent_verification UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_consent UUID NOT NULL,
    token VARCHAR(255) NOT NULL,
    expiration_date TIMESTAMPTZ NOT NULL,
    used BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ
);

-- TERMS ACCEPTANCE
CREATE TABLE legal.terms_acceptance (
    id_acceptance UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_users UUID NOT NULL,
    accepted BOOLEAN NOT NULL,
    origin_ip INET,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ
);
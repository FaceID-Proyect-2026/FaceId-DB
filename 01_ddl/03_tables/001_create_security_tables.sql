CREATE TABLE security.type_document(
    id_type_document UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    abbreviation VARCHAR(20) NOT NULL UNIQUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_type_document_name
        CHECK (name IN ('CITIZENSHIP CARD', 'FOREIGNER IDENTITY CARD', 'IDENTITY CARD', 'PASSPORT')),
    CONSTRAINT chk_type_document_abbreviation
        CHECK (abbreviation IN ('CC', 'CE', 'TI', 'PAS'))
);

CREATE TABLE security.user_app(
    id_users UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_type_document UUID NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE NOT NULL,
    account_status VARCHAR(20) NOT NULL DEFAULT 'PENDING_CONSENT',
    number_document VARCHAR(50) NOT NULL UNIQUE,
    email_verification BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_account_status 
        CHECK (account_status IN ('ACTIVE', 'INACTIVE', 'PENDING_CONSENT', 'BLOCKED'))
);

CREATE TABLE security.credential(
    id_credential UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_users UUID NOT NULL,
    email VARCHAR(255) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    credential_status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    failed_attempts INTEGER NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_credential_status 
        CHECK (credential_status IN ('ACTIVE', 'INACTIVE', 'BLOCKED')),
    CONSTRAINT chk_failed_attempts_non_negative
        CHECK (failed_attempts >= 0)
);

CREATE TABLE security.email_verification (
    id_email_verification UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_users UUID NOT NULL,
    code VARCHAR(6) NOT NULL,
    expires_at TIMESTAMPTZ NOT NULL,
    used BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_email_verification_expires_at
        CHECK (expires_at > created_at)
);

CREATE TABLE security.password_recovery (
    id_password_recovery UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_users UUID NOT NULL,
    token VARCHAR(255) NOT NULL,
    request_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expiration_date TIMESTAMPTZ NOT NULL,
    used BOOLEAN NOT NULL DEFAULT FALSE,
    state VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_password_recovery_status 
        CHECK (state IN ('ACTIVE', 'INACTIVE')),
    CONSTRAINT chk_password_recovery_expiration_date
        CHECK (expiration_date > request_date)
);

CREATE TABLE security.user_session (
    id_user_session UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_users UUID NOT NULL,
    start_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    end_date TIMESTAMPTZ,
    source_ip INET,
    session_status VARCHAR(20) NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_session_status 
        CHECK (session_status IN ('ACTIVE', 'INACTIVE')),
    CONSTRAINT chk_session_start_date
        CHECK (end_date IS NULL OR end_date >= start_date)
);

CREATE TABLE security.user_configuration (
    id_user_configuration UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_users UUID NOT NULL,
    configuration_name VARCHAR(100) NOT NULL,
    description VARCHAR(255),
    notifications_active BOOLEAN NOT NULL DEFAULT TRUE,
    dark_mode BOOLEAN NOT NULL DEFAULT FALSE,
    update_date TIMESTAMPTZ DEFAULT NOW(),
    language VARCHAR(20) NOT NULL,
    dashboard_theme VARCHAR(50),
    primary_color VARCHAR(50),
    secondary_color VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_language 
        CHECK (language IN ('ES','EN','DE','PT'))
);
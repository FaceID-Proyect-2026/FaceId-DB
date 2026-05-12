CREATE TABLE security."user"(
    id_user UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    document_number VARCHAR(10) NOT NULL UNIQUE,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    birth_date DATE NOT NULL,
    account_status VARCHAR(20) NOT NULL DEFAULT 'PENDING_CONSENT',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_account_status 
        CHECK (account_status 
        IN ('ACTIVE', 'INACTIVE', 'PENDING_CONSENT', 'BLOCKED')) 
);

CREATE TABLE security.credential(
    id_credential UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_user UUID NOT NULL,
    email VARCHAR(50) NOT NULL UNIQUE,
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
        CHECK (credential_status 
        IN ('ACTIVE', 'INACTIVE', 'BLOCKED')),
    CONSTRAINT chk_failed_attempts_non_negative
        CHECK (failed_attempts >= 0),
    CONSTRAINT fk_credential_user
        FOREIGN KEY (id_user) 
        REFERENCES security."user"(id_user)
);

CREATE TABLE security.password_recovery (
    id_password_recovery UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_user UUID NOT NULL,
    token VARCHAR(255),
    request_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    expiration_date TIMESTAMPTZ,
    used BOOLEAN NOT NULL DEFAULT FALSE,
    state VARCHAR(20),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_password_recovery_status 
        CHECK (state 
        IN ('ACTIVE', 'INACTIVE')),
    CONSTRAINT fk_password_recovery_user
        FOREIGN KEY (id_user) 
        REFERENCES security."user"(id_user)
);

CREATE TABLE security.user_session (
    id_user_session UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_user UUID NOT NULL,
    start_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    end_date TIMESTAMPTZ,
    source_ip VARCHAR(50),
    session_status VARCHAR(20),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT fk_session_user
        FOREIGN KEY (id_user) 
        REFERENCES security."user"(id_user),
    CONSTRAINT chk_session_status 
        CHECK (session_status 
        IN ('ACTIVE', 'INACTIVE'))
);
CREATE TABLE credential (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    credential_status VARCHAR(20) NOT NULL,
    failed_attempts INTEGER NOT NULL DEFAULT 0,
    id_user BIGINT NOT NULL,
    CONSTRAINT uq_credential_email UNIQUE (email),
    CONSTRAINT chk_credential_status 
    CHECK (credential_status IN ('ACTIVE', 'INACTIVE', 'BLOCKED')),
    CONSTRAINT chk_failed_attempts_non_negative
    CHECK (failed_attempts >= 0),
    CONSTRAINT fk_credential_user
    FOREIGN KEY (id_user) REFERENCES "user"(id_user)
);
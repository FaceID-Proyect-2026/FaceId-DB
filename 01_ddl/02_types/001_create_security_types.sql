-- =========================
-- ENUM TYPES
-- =========================

CREATE TYPE security.type_document_name_type AS ENUM (
    'CITIZENSHIP CARD',
    'FOREIGNER IDENTITY CARD',
    'IDENTITY CARD',
    'PASSPORT'
);

CREATE TYPE security.type_document_abbreviation_type AS ENUM (
    'CC',
    'CE',
    'TI',
    'PAS'
);

CREATE TYPE security.account_status_type AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'PENDING_CONSENT',
    'BLOCKED'
);

CREATE TYPE security.credential_status_type AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'BLOCKED'
);

CREATE TYPE security.password_recovery_state_type AS ENUM (
    'ACTIVE',
    'INACTIVE'
);

CREATE TYPE security.session_status_type AS ENUM (
    'ACTIVE',
    'INACTIVE'
);

CREATE TYPE security.language_type AS ENUM (
    'ES',
    'EN',
    'DE',
    'PT'
);
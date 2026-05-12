CREATE TABLE legal.terms_conditions (
    id_terms UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    type VARCHAR(50) NOT NULL,
    terms_text TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
);

CREATE TABLE legal.terms_acceptance (
    id_acceptance UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_user UUID NOT NULL,
    id_terms UUID NOT NULL,
    accepted VARCHAR(10) NOT NULL,
    acceptance_date TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT fk_acceptance_user
        FOREIGN KEY (id_user) 
        REFERENCES security."user"(id_user),
    CONSTRAINT fk_acceptance_terms
        FOREIGN KEY (id_terms) 
        REFERENCES legal.terms_conditions(id_terms)

);

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
    CONSTRAINT fk_consent_user
        FOREIGN KEY (id_user) 
        REFERENCES security."user"(id_user),
    CONSTRAINT fk_consent_guardian
        FOREIGN KEY (id_guardian) 
        REFERENCES legal.guardian(id_guardian)
);
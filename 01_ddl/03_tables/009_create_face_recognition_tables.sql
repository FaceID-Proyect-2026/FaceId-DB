CREATE TABLE security.face_embedding (
    id_face_embedding UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_user_app UUID NOT NULL,
    embedding JSONB NOT NULL,
    model_name VARCHAR(100) NOT NULL,
    embedding_version VARCHAR(20) NOT NULL DEFAULT 'v1',
    active BOOLEAN NOT NULL DEFAULT TRUE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_face_embedding_json_array
        CHECK (jsonb_typeof(embedding) = 'array')
);

CREATE UNIQUE INDEX uk_face_embedding_active_user
    ON security.face_embedding (id_user_app)
    WHERE active = TRUE AND deleted_at IS NULL;

CREATE INDEX idx_face_embedding_user
    ON security.face_embedding (id_user_app);

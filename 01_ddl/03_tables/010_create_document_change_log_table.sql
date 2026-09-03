-- 01_ddl/03_tables/010_create_document_change_log_table.sql

CREATE TABLE security.document_change_log (
    id_document_change UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_user_app UUID NOT NULL,
    old_document VARCHAR(50) NOT NULL,
    new_document VARCHAR(50) NOT NULL,
    changed_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    changed_by VARCHAR(100) NOT NULL,
    reason VARCHAR(255),
    CONSTRAINT chk_document_change_different
        CHECK (old_document <> new_document)
);
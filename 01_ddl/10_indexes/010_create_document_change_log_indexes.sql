-- 01_ddl/10_indexes/010_create_document_change_log_indexes.sql

CREATE INDEX idx_document_change_log_user
ON security.document_change_log(id_user_app);
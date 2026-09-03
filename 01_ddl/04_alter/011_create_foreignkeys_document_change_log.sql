-- 01_ddl/04_alter/011_create_foreignkeys_document_change_log.sql

ALTER TABLE security.document_change_log
ADD CONSTRAINT fk_document_change_log_user
FOREIGN KEY (id_user_app)
REFERENCES security.user_app (id_user_app);
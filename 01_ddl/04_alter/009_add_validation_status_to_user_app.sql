-- 01_ddl/04_alter/009_add_validation_status_to_user_app.sql

ALTER TABLE security.user_app
  ADD COLUMN validation_status VARCHAR(20) NOT NULL DEFAULT 'PENDING_VALIDATION';

ALTER TABLE security.user_app
  ADD CONSTRAINT chk_user_app_validation_status
  CHECK (validation_status IN ('PENDING_VALIDATION', 'VALIDATED', 'INCONSISTENCY'));
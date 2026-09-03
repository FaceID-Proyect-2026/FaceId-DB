ALTER TABLE security.user_app
  DROP CONSTRAINT chk_user_app_validation_status;

ALTER TABLE security.user_app
  DROP COLUMN validation_status;
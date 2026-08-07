ALTER TABLE security.user_configuration
DROP CONSTRAINT fk_user_configuration_users;

ALTER TABLE security.user_session
DROP CONSTRAINT fk_user_session_users;

ALTER TABLE security.password_recovery
DROP CONSTRAINT fk_password_recovery_users;

ALTER TABLE security.email_verification
DROP CONSTRAINT fk_email_verification_users;

ALTER TABLE security.credential
DROP CONSTRAINT fk_credential_users;

ALTER TABLE security.user_app
DROP CONSTRAINT fk_users_type_document;
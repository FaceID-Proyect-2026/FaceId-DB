CREATE INDEX idx_user_app_id_type_document
ON security.user_app(id_type_document);

CREATE INDEX idx_user_app_account_status
ON security.user_app(account_status);

CREATE INDEX idx_credential_id_user_app
ON security.credential(id_user_app);

CREATE INDEX idx_credential_status
ON security.credential(credential_status);

CREATE INDEX idx_email_verification_id_user_app
ON security.email_verification(id_user_app);

CREATE INDEX idx_email_verification_pending
ON security.email_verification(code, expires_at)
WHERE used = FALSE;

CREATE INDEX idx_password_recovery_id_user_app
ON security.password_recovery(id_user_app);

CREATE INDEX idx_password_recovery_token
ON security.password_recovery(token);

CREATE INDEX idx_password_recovery_expiration_date
ON security.password_recovery(expiration_date);

CREATE INDEX idx_user_session_id_user_app
ON security.user_session(id_user_app);

CREATE INDEX idx_user_session_status
ON security.user_session(session_status);

CREATE INDEX idx_user_configuration_id_user_app
ON security.user_configuration(id_user_app);
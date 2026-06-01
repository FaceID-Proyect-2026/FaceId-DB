ALTER TABLE security.user_app
ADD CONSTRAINT fk_users_type_document
FOREIGN KEY (id_type_document)
REFERENCES security.type_document (id_type_document);

ALTER TABLE security.credential
ADD CONSTRAINT fk_credential_users
FOREIGN KEY (id_users)
REFERENCES security.user_app (id_users);

ALTER TABLE security.email_verification
ADD CONSTRAINT fk_email_verification_users
FOREIGN KEY (id_users)
REFERENCES security.user_app (id_users);

ALTER TABLE security.password_recovery
ADD CONSTRAINT fk_password_recovery_users
FOREIGN KEY (id_users)
REFERENCES security.user_app (id_users);

ALTER TABLE security.user_session
ADD CONSTRAINT fk_user_session_users
FOREIGN KEY (id_users)
REFERENCES security.user_app (id_users);

ALTER TABLE security.user_configuration
ADD CONSTRAINT fk_user_configuration_users
FOREIGN KEY (id_users)
REFERENCES security.user_app (id_users);
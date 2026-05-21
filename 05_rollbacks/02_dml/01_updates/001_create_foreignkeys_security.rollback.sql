-- 1. DROP FK: user_configuration -> users
ALTER TABLE security.user_configuration
DROP CONSTRAINT fk_user_configuration_users;

-- 2. DROP FK: user_session -> users
ALTER TABLE security.user_session
DROP CONSTRAINT fk_user_session_users;

-- 3. DROP FK: password_recovery -> users
ALTER TABLE security.password_recovery
DROP CONSTRAINT fk_password_recovery_users;

-- 4. DROP FK: email_verification -> users
ALTER TABLE security.email_verification
DROP CONSTRAINT fk_email_verification_users;

-- 5. DROP FK: credential -> users
ALTER TABLE security.credential
DROP CONSTRAINT fk_credential_users;

-- 6. DROP FK: users -> type_document
ALTER TABLE security.users
DROP CONSTRAINT fk_users_type_document;
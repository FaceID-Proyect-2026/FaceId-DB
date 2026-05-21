-- 1. Tablas que dependen de users

DROP TABLE IF EXISTS security.user_configuration;

DROP TABLE IF EXISTS security.user_session;

DROP TABLE IF EXISTS security.password_recovery;

DROP TABLE IF EXISTS security.email_verification;

DROP TABLE IF EXISTS security.credential;

-- 2. Tabla dependiente de type_document

DROP TABLE IF EXISTS security.users;

-- 3. Tabla padre

DROP TABLE IF EXISTS security.type_document;
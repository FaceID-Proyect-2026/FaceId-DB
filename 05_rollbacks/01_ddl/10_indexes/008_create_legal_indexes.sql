DROP INDEX IF EXISTS legal.uq_terms_acceptance_active;

DROP INDEX IF EXISTS legal.idx_terms_acceptance_active;

DROP INDEX IF EXISTS legal.idx_terms_acceptance_user;

DROP INDEX IF EXISTS legal.idx_consent_verification_expiration;

DROP INDEX IF EXISTS legal.idx_consent_verification_valid;

DROP INDEX IF EXISTS legal.idx_consent_verification_consent;

DROP INDEX IF EXISTS legal.uq_consent_verification_token;

DROP INDEX IF EXISTS legal.idx_consent_response_date;

DROP INDEX IF EXISTS legal.idx_consent_application_date;

DROP INDEX IF EXISTS legal.idx_consent_status;

DROP INDEX IF EXISTS legal.idx_consent_pending;

DROP INDEX IF EXISTS legal.idx_consent_guardian;

DROP INDEX IF EXISTS legal.idx_consent_user;

DROP INDEX IF EXISTS legal.uq_guardian_email_active;

DROP INDEX IF EXISTS legal.uq_guardian_identity_active;

DROP INDEX IF EXISTS legal.idx_guardian_full_name;
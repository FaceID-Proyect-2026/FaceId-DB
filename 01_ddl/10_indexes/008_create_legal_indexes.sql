CREATE INDEX idx_guardian_full_name
ON legal.guardian(full_name);

CREATE UNIQUE INDEX uq_guardian_identity_active
ON legal.guardian(identity_document)
WHERE deleted_at IS NULL;

CREATE UNIQUE INDEX uq_guardian_email_active
ON legal.guardian(guardian_email)
WHERE deleted_at IS NULL;

CREATE INDEX idx_consent_user
ON legal.consent(id_user_app);

CREATE INDEX idx_consent_guardian
ON legal.consent(id_guardian);

CREATE INDEX idx_consent_pending
ON legal.consent(id_user_app,consent_status)
WHERE deleted_at IS NULL;

CREATE INDEX idx_consent_status
ON legal.consent(consent_status);

CREATE INDEX idx_consent_application_date
ON legal.consent(application_date);

CREATE INDEX idx_consent_response_date
ON legal.consent(response_date);

CREATE UNIQUE INDEX uq_consent_verification_token
ON legal.consent_verification(token);

CREATE INDEX idx_consent_verification_consent
ON legal.consent_verification(id_consent);

CREATE INDEX idx_consent_verification_valid
ON legal.consent_verification(token,expiration_date)
WHERE used = FALSE;

CREATE INDEX idx_consent_verification_expiration
ON legal.consent_verification(expiration_date);

CREATE INDEX idx_terms_acceptance_user
ON legal.terms_acceptance(id_user_app);

CREATE INDEX idx_terms_acceptance_active
ON legal.terms_acceptance(id_user_app)
WHERE accepted = TRUE
AND deleted_at IS NULL;

CREATE UNIQUE INDEX uq_terms_acceptance_active
ON legal.terms_acceptance(id_user_app)
WHERE accepted = TRUE
AND deleted_at IS NULL;
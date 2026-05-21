ALTER TABLE legal.terms_acceptance
DROP CONSTRAINT fk_terms_acceptance_users;

ALTER TABLE legal.consent_verification
DROP CONSTRAINT fk_consent_verification_consent;

ALTER TABLE legal.consent
DROP CONSTRAINT fk_consent_users;

ALTER TABLE legal.consent
DROP CONSTRAINT fk_consent_guardian;
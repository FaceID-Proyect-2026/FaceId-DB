ALTER TABLE legal.consent
ADD CONSTRAINT fk_consent_guardian
FOREIGN KEY (id_guardian)
REFERENCES legal.guardian (id_guardian);

ALTER TABLE legal.consent
ADD CONSTRAINT fk_consent_users
FOREIGN KEY (id_users)
REFERENCES security.user_app (id_users);

ALTER TABLE legal.consent_verification
ADD CONSTRAINT fk_consent_verification_consent
FOREIGN KEY (id_consent)
REFERENCES legal.consent (id_consent);

ALTER TABLE legal.terms_acceptance
ADD CONSTRAINT fk_terms_acceptance_users
FOREIGN KEY (id_users)
REFERENCES security.user_app (id_users);
ALTER TABLE facialrecognition.user_face
ADD CONSTRAINT fk_user_face_user_app
FOREIGN KEY (id_user_app)
REFERENCES security.user_app (id_user_app);

ALTER TABLE facialrecognition.facial_event
ADD CONSTRAINT fk_facial_event_user_app
FOREIGN KEY (id_user_app)
REFERENCES security.user_app (id_user_app);

ALTER TABLE facialrecognition.facial_event
ADD CONSTRAINT fk_facial_event_environment
FOREIGN KEY (id_environment)
REFERENCES environment.environment (id_environment);

ALTER TABLE facialrecognition.facial_event
ADD CONSTRAINT fk_facial_event_chip
FOREIGN KEY (id_chip)
REFERENCES academic.chip (id_chip);

ALTER TABLE facialrecognition.facial_event
ADD CONSTRAINT fk_facial_event_device
FOREIGN KEY (id_device)
REFERENCES facialrecognition.device (id_device);

ALTER TABLE facialrecognition.biometric_log
ADD CONSTRAINT fk_biometric_log_facial_event
FOREIGN KEY (id_facial_event)
REFERENCES facialrecognition.facial_event (id_facial_event);
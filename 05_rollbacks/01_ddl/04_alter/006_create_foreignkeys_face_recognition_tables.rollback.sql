ALTER TABLE facialrecognition.biometric_log
DROP CONSTRAINT IF EXISTS fk_biometric_log_facial_event;

ALTER TABLE facialrecognition.facial_event
DROP CONSTRAINT IF EXISTS fk_facial_event_device;

ALTER TABLE facialrecognition.facial_event
DROP CONSTRAINT IF EXISTS fk_facial_event_chip;

ALTER TABLE facialrecognition.facial_event
DROP CONSTRAINT IF EXISTS fk_facial_event_environment;

ALTER TABLE facialrecognition.facial_event
DROP CONSTRAINT IF EXISTS fk_facial_event_user_app;

ALTER TABLE facialrecognition.user_face
DROP CONSTRAINT IF EXISTS fk_user_face_user_app;
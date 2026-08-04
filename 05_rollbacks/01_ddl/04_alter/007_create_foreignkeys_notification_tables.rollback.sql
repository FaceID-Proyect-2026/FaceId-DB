ALTER TABLE notification.email_send
    DROP CONSTRAINT IF EXISTS fk_email_send_notification;

ALTER TABLE notification.notification
    DROP CONSTRAINT IF EXISTS fk_notification_face_event;

ALTER TABLE notification.notification
    DROP CONSTRAINT IF EXISTS fk_notification_user_app;
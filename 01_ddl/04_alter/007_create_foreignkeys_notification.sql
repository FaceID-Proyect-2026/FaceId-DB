ALTER TABLE notification.notification
    ADD CONSTRAINT fk_notification_user_app
        FOREIGN KEY (user_id)
        REFERENCES security.user_app (id_user_app);

ALTER TABLE notification.notification
    ADD CONSTRAINT fk_notification_face_event
        FOREIGN KEY (face_event_id)
        REFERENCES facialrecognition.face_event (id_face_event);

ALTER TABLE notification.email_send
    ADD CONSTRAINT fk_email_send_notification
        FOREIGN KEY (notification_id)
        REFERENCES notification.notification (id_notification);
CREATE TABLE notification.notification (
    id_notification UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL,
    face_event_id UUID NULL,
    notification_type notification.notification_type NOT NULL,
    title VARCHAR(100) NOT NULL,
    message VARCHAR(255) NOT NULL,
    event_at TIMESTAMPTZ NOT NULL,
    notification_status notification.notification_status NOT NULL,
    channel notification.notification_channel NOT NULL,
    event_source notification.notification_event_source NOT NULL,
    priority VARCHAR(20),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE notification.email_send (
    id_email_send UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    notification_id UUID NOT NULL,
    destination_email VARCHAR(150) NOT NULL,
    sent_at TIMESTAMPTZ,
    send_status notification.email_send_status NOT NULL,
    attempts INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ
);
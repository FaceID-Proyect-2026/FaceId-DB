CREATE TABLE notification.notification (
    id_notification UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_user_app UUID NOT NULL,
    id_facial_event UUID NULL,
    notification_type VARCHAR(50) NOT NULL,
    title VARCHAR(100) NOT NULL,
    message VARCHAR(255) NOT NULL,
    event_at TIMESTAMPTZ NOT NULL,
    notification_status VARCHAR(50) NOT NULL,
    channel VARCHAR(50) NOT NULL,
    event_source VARCHAR(50) NOT NULL,
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
    id_notification UUID NOT NULL,
    destination_email VARCHAR(150) NOT NULL,
    sent_at TIMESTAMPTZ,
    send_status VARCHAR(50) NOT NULL,
    attempts INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ
);
CREATE TYPE notification.notification_type AS ENUM ('ALERT', 'NOTICE', 'REMINDER');
CREATE TYPE notification.notification_status AS ENUM ('READ', 'UNREAD');
CREATE TYPE notification.notification_channel AS ENUM ('INTERNAL', 'EMAIL', 'BOTH');
CREATE TYPE notification.notification_event_source AS ENUM ('ATTENDANCE', 'ANOMALY', 'SCHEDULE', 'SYSTEM');
CREATE TYPE notification.email_send_status AS ENUM ('SENT', 'PENDING', 'ERROR');
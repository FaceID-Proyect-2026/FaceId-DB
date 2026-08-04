CREATE TABLE facialrecognition.device (
    id_device UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    device_code VARCHAR(50) NOT NULL,
    location VARCHAR(100),
    status facialrecognition.device_status NOT NULL,
    origin_ip VARCHAR(50),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE facialrecognition.user_face (
    id_user_face UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_user_app UUID NOT NULL,
    biometric_vector BYTEA NOT NULL,
    registration_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    status facialrecognition.face_status NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE facialrecognition.facial_event (
    id_facial_event UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_user_app UUID NULL,
    id_environment UUID NOT NULL,
    id_chip UUID NULL,
    id_device UUID NOT NULL,
    event_datetime TIMESTAMPTZ NOT NULL,
    event_type facialrecognition.event_type NOT NULL,
    recognition_result facialrecognition.recognition_result NOT NULL,
    send_status facialrecognition.send_status NOT NULL,
    origin facialrecognition.event_origin NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ
);

CREATE TABLE facialrecognition.biometric_log (
    id_biometric_log UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_event UUID NOT NULL,
    description TEXT,
    log_date TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ
);
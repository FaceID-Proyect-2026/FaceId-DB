CREATE TYPE facialrecognition.device_status AS ENUM ('ACTIVE', 'INACTIVE');

CREATE TYPE facialrecognition.face_status AS ENUM ('ACTIVE', 'PENDING', 'INACTIVE');

CREATE TYPE facialrecognition.event_type AS ENUM ('ENTRY', 'BREAK', 'EXIT');

CREATE TYPE facialrecognition.recognition_result AS ENUM ('RECOGNIZED', 'NOT_RECOGNIZED');

CREATE TYPE facialrecognition.send_status AS ENUM ('PENDING', 'SENT');

CREATE TYPE facialrecognition.event_origin AS ENUM ('ONLINE', 'OFFLINE');
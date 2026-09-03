-- 01_ddl/03_tables/009_create_transfer_request_table.sql

CREATE TABLE academic.transfer_request (
    id_transfer_request UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    id_user_app UUID NOT NULL,
    id_current_chip UUID NOT NULL, --academic.chip
    id_requested_chip UUID NOT NULL, -- academic.chip
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING',
    requested_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    decided_at TIMESTAMPTZ,
    decided_by VARCHAR(100),
    reason VARCHAR(255),
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    created_by VARCHAR(100),
    updated_at TIMESTAMPTZ,
    updated_by VARCHAR(100),
    deleted_by VARCHAR(100),
    deleted_at TIMESTAMPTZ,
    CONSTRAINT chk_transfer_request_status
        CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
    CONSTRAINT chk_transfer_request_different_chip
        CHECK (id_current_chip <> id_requested_chip)
);
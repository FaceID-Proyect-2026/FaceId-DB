-- 01_ddl/10_indexes/009_create_transfer_request_indexes.sql

CREATE INDEX idx_transfer_request_user
ON academic.transfer_request(id_user_app);

CREATE INDEX idx_transfer_request_status
ON academic.transfer_request(status);

-- Evita que un mismo aprendiz tenga más de una solicitud PENDING a la vez
CREATE UNIQUE INDEX uq_transfer_request_one_pending_per_user
ON academic.transfer_request(id_user_app)
WHERE status = 'PENDING' AND deleted_at IS NULL;
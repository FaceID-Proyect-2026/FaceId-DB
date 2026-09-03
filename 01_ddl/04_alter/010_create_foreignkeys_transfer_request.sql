-- 01_ddl/04_alter/010_create_foreignkeys_transfer_request.sql

ALTER TABLE academic.transfer_request
ADD CONSTRAINT fk_transfer_request_user
FOREIGN KEY (id_user_app)
REFERENCES security.user_app (id_user_app);

ALTER TABLE academic.transfer_request
ADD CONSTRAINT fk_transfer_request_current_chip
FOREIGN KEY (id_current_chip)
REFERENCES academic.chip (id_chip);

ALTER TABLE academic.transfer_request
ADD CONSTRAINT fk_transfer_request_requested_chip
FOREIGN KEY (id_requested_chip)
REFERENCES academic.chip (id_chip);
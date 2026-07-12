ALTER TABLE academic.chip
ADD CONSTRAINT fk_chip_program
FOREIGN KEY (id_program)
REFERENCES academic.program (id_program);

ALTER TABLE academic.user_chip
ADD CONSTRAINT fk_user_chip_users
FOREIGN KEY (id_user_app)
REFERENCES security.user_app (id_user_app);

ALTER TABLE academic.user_chip
ADD CONSTRAINT fk_user_chip_chip
FOREIGN KEY (id_chip)
REFERENCES academic.chip (id_chip);
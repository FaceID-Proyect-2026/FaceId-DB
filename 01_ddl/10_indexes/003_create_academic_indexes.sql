CREATE INDEX idx_program_active
ON academic.program(id_program)
WHERE deleted_at IS NULL;

CREATE INDEX idx_program_state
ON academic.program(state);

CREATE INDEX idx_chip_program
ON academic.chip(id_program);

CREATE INDEX idx_chip_program_active
ON academic.chip(id_program)
WHERE deleted_at IS NULL;

CREATE INDEX idx_chip_code
ON academic.chip(chip_code);

CREATE INDEX idx_chip_name
ON academic.chip(chip_name);

CREATE INDEX idx_chip_state
ON academic.chip(state);

CREATE INDEX idx_user_chip_user
ON academic.user_chip(id_user_app);

CREATE INDEX idx_user_chip_chip
ON academic.user_chip(id_chip);

CREATE UNIQUE INDEX uq_user_chip_active
ON academic.user_chip(id_user_app,id_chip)
WHERE deleted_at IS NULL;

CREATE INDEX idx_user_chip_user_active
ON academic.user_chip(id_user_app)
WHERE deleted_at IS NULL;

CREATE INDEX idx_user_chip_state
ON academic.user_chip(state);

CREATE INDEX idx_user_chip_assignment_date
ON academic.user_chip(assignment_date);
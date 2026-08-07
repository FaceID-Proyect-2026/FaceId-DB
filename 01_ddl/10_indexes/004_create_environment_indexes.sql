CREATE INDEX idx_environment_name
ON environment.environment(environment_name);

CREATE INDEX idx_environment_status
ON environment.environment(status);

CREATE INDEX idx_environment_active
ON environment.environment(id_environment)
WHERE deleted_at IS NULL;

CREATE INDEX idx_chip_environment_chip
ON environment.chip_environment(id_chip);

CREATE INDEX idx_chip_environment_environment
ON environment.chip_environment(id_environment);

CREATE UNIQUE INDEX uq_chip_environment_active
ON environment.chip_environment(id_chip,id_environment)
WHERE deleted_at IS NULL;

CREATE INDEX idx_chip_environment_environment_active
ON environment.chip_environment(id_environment)
WHERE deleted_at IS NULL;

CREATE INDEX idx_chip_environment_assignment_date
ON environment.chip_environment(assignment_date);

CREATE INDEX idx_chip_environment_status
ON environment.chip_environment(status);

CREATE INDEX idx_record_environment_environment
ON environment.record_environment(id_environment);

CREATE INDEX idx_record_environment_schedule
ON environment.record_environment(id_schedule);

CREATE INDEX idx_record_environment_available
ON environment.record_environment(id_environment,id_schedule)
WHERE deleted_at IS NULL;

CREATE INDEX idx_record_environment_date
ON environment.record_environment(assignment_date);

CREATE INDEX idx_record_environment_active
ON environment.record_environment(active);
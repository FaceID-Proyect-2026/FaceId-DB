ALTER TABLE environment.record_environment
ADD CONSTRAINT fk_record_environment_environment
FOREIGN KEY (id_environment)
REFERENCES environment.environment (id_environment);
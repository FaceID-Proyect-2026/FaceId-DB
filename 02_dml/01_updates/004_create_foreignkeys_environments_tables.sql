ALTER TABLE environments.record_environment
ADD CONSTRAINT fk_record_environment_environment
FOREIGN KEY (id_environment)
REFERENCES environments.environment (id_environment);
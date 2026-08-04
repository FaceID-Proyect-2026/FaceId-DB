CREATE INDEX idx_schedule_chip
ON schedule.schedule(id_chip);

CREATE INDEX idx_schedule_chip_active
ON schedule.schedule(id_chip)
WHERE deleted_at IS NULL;

CREATE INDEX idx_schedule_day
ON schedule.schedule(day_of_week);

CREATE INDEX idx_schedule_time_range
ON schedule.schedule(start_time,end_time);

CREATE INDEX idx_schedule_status
ON schedule.schedule(status);

CREATE INDEX idx_schedule_creation_date
ON schedule.schedule(creation_date);

CREATE INDEX idx_schedule_instructor_schedule
ON schedule.schedule_instructor(id_schedule);

CREATE INDEX idx_schedule_instructor_user
ON schedule.schedule_instructor(id_user_app);

CREATE UNIQUE INDEX uq_schedule_instructor_active
ON schedule.schedule_instructor(id_schedule,id_user_app)
WHERE deleted_at IS NULL;

CREATE INDEX idx_schedule_instructor_active
ON schedule.schedule_instructor(id_schedule)
WHERE deleted_at IS NULL;

CREATE INDEX idx_schedule_exception_schedule
ON schedule.schedule_exception(id_schedule);

CREATE INDEX idx_schedule_exception_environment
ON schedule.schedule_exception(id_environment);

CREATE INDEX idx_schedule_exception_lookup
ON schedule.schedule_exception(id_schedule,exception_date)
WHERE deleted_at IS NULL;

CREATE INDEX idx_schedule_exception_date
ON schedule.schedule_exception(exception_date);

CREATE INDEX idx_schedule_exception_status
ON schedule.schedule_exception(status);
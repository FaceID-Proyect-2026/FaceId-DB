-- schedule
ALTER TABLE schedule.schedule
DROP CONSTRAINT IF EXISTS fk_schedule_chip;

-- instructor_schedule
ALTER TABLE schedule.instructor_schedule
DROP CONSTRAINT IF EXISTS fk_instructor_schedule_schedule;

ALTER TABLE schedule.instructor_schedule
DROP CONSTRAINT IF EXISTS fk_instructor_schedule_instructor;

-- schedule_exception
ALTER TABLE schedule.schedule_exception
DROP CONSTRAINT IF EXISTS fk_schedule_exception_schedule;
ALTER TABLE schedule.schedule_exception
DROP CONSTRAINT IF EXISTS fk_schedule_exception_schedule;

ALTER TABLE schedule.schedule_instructor
DROP CONSTRAINT IF EXISTS fk_schedule_instructor_user;

ALTER TABLE schedule.schedule_instructor
DROP CONSTRAINT IF EXISTS fk_schedule_instructor_schedule;

ALTER TABLE schedule.schedule
DROP CONSTRAINT IF EXISTS fk_schedule_chip;

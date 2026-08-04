ALTER TABLE schedule.schedule
ADD CONSTRAINT fk_schedule_chip
FOREIGN KEY (id_chip)
REFERENCES academic.chip(id_chip);

ALTER TABLE schedule.schedule_instructor
ADD CONSTRAINT fk_instructor_schedule_schedule
FOREIGN KEY (id_schedule)
REFERENCES schedule.schedule(id_schedule);

ALTER TABLE schedule.schedule_instructor
ADD CONSTRAINT fk_instructor_schedule_instructor
FOREIGN KEY (id_user_app)
REFERENCES security.user_app(id_user_app);

ALTER TABLE schedule.schedule_exception
ADD CONSTRAINT fk_schedule_exception_schedule
FOREIGN KEY (id_schedule)
REFERENCES schedule.schedule(id_schedule);

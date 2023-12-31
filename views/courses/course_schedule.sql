CREATE VIEW course_schedule AS
SELECT
    courses.activity_id AS course_id,
    FORMAT(MIN(meeting_schedule.start_time), 'yyyy-MM-dd') AS start_day,
    FORMAT(MAX(meeting_schedule.end_time), 'yyyy-MM-dd') AS end_day
FROM courses
    JOIN course_modules ON courses.activity_id = course_modules.course_id
    JOIN module_meetings ON course_modules.activity_id = module_meetings.module_id
    LEFT JOIN meeting_schedule ON module_meetings.meeting_id = meeting_schedule.meeting_id
GROUP BY courses.activity_id

CREATE VIEW course_meeting_information AS
SELECT
    course_modules.course_id AS course_id,
    course_modules.activity_id AS module_id,
    module_meetings.meeting_id AS meeting_id,
    MA.title AS title,
    MA.description AS description,
    CASE
        WHEN meetings.activity_id NOT IN (SELECT meeting_id FROM internships) AND
             meetings.activity_id IN (SELECT meeting_id FROM online_asynchronous_meetings) AND
             meetings.activity_id NOT IN (SELECT meeting_id FROM online_synchronous_meetings) AND
             meetings.activity_id NOT IN (SELECT meeting_id FROM on_site_meetings)
        THEN 'online_asynchronous'

        WHEN meetings.activity_id NOT IN (SELECT meeting_id FROM internships) AND
             meetings.activity_id NOT IN (SELECT meeting_id FROM online_asynchronous_meetings) AND
             meetings.activity_id IN (SELECT meeting_id FROM online_synchronous_meetings) AND
             meetings.activity_id NOT IN (SELECT meeting_id FROM on_site_meetings)
        THEN 'online_synchronous'

        WHEN meetings.activity_id NOT IN (SELECT meeting_id FROM internships) AND
             meetings.activity_id NOT IN (SELECT meeting_id FROM online_asynchronous_meetings) AND
             meetings.activity_id NOT IN (SELECT meeting_id FROM online_synchronous_meetings) AND
             meetings.activity_id IN (SELECT meeting_id FROM on_site_meetings)
        THEN 'on_site'
    END AS meeting_type,
    meeting_schedule.start_time AS start_time,
    meeting_schedule.end_time AS end_time
FROM course_modules
    JOIN module_meetings ON course_modules.activity_id = module_meetings.module_id
    JOIN meetings ON module_meetings.meeting_id = meetings.activity_id
    JOIN activities MA ON meetings.activity_id = MA.id
    LEFT JOIN meeting_schedule ON meetings.activity_id = meeting_schedule.meeting_id

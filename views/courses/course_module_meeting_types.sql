CREATE VIEW course_module_meeting_types AS
SELECT
    course_modules.activity_id AS module_id,
    (
        SELECT COUNT(*)
        FROM module_meetings
            JOIN meetings ON module_meetings.meeting_id = meetings.activity_id
            JOIN on_site_meetings ON meetings.activity_id = on_site_meetings.meeting_id
        WHERE module_meetings.module_id = course_modules.activity_id
    ) AS on_site_meeting_count,
    (
        SELECT COUNT(*)
        FROM module_meetings
            JOIN meetings ON module_meetings.meeting_id = meetings.activity_id
            JOIN online_synchronous_meetings ON meetings.activity_id = online_synchronous_meetings.meeting_id
        WHERE module_meetings.module_id = course_modules.activity_id
    ) AS online_synchronous_meeting_count,
    (
        SELECT COUNT(*)
        FROM module_meetings
            JOIN meetings ON module_meetings.meeting_id = meetings.activity_id
            JOIN online_asynchronous_meetings ON meetings.activity_id = online_asynchronous_meetings.meeting_id
        WHERE module_meetings.module_id = course_modules.activity_id
    ) AS online_asynchronous_meeting_count
FROM course_modules

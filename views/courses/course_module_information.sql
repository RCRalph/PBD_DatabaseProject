CREATE VIEW course_module_information AS
SELECT
    module_id,
    CASE
        WHEN on_site_meeting_count <> 0 AND
             online_synchronous_meeting_count = 0 AND
             online_asynchronous_meeting_count = 0 THEN 'on_site'
        WHEN on_site_meeting_count = 0 AND
             online_synchronous_meeting_count <> 0 AND
             online_asynchronous_meeting_count = 0 THEN 'online_synchronous'
        WHEN on_site_meeting_count = 0 AND
             online_synchronous_meeting_count = 0 AND
             online_asynchronous_meeting_count <> 0 THEN 'online_asynchronous'
        WHEN on_site_meeting_count <> 0 OR
             online_synchronous_meeting_count <> 0 OR
             online_asynchronous_meeting_count <> 0 THEN 'hybrid'
    END AS module_type,
    CASE WHEN on_site_meeting_count <> 0 THEN (
        SELECT MIN(rooms.place_limit)
        FROM module_meetings
            JOIN on_site_meetings ON module_meetings.meeting_id = on_site_meetings.meeting_id
            JOIN rooms ON on_site_meetings.room_id = rooms.id
        WHERE module_meetings.module_id = course_module_meeting_types.module_id
    ) END AS place_limit,
    dbo.get_course_module_language(module_id) AS language
FROM course_module_meeting_types

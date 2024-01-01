CREATE VIEW study_meeting_information AS
SELECT
    study_modules.study_id,
    study_meetings.module_id,
    study_meetings.session_id,
    study_meetings.meeting_id,
    activities.title,
    activities.description,
    meeting_schedule.start_time,
    meeting_schedule.end_time,
    CASE
        WHEN meetings.activity_id IN (SELECT meeting_id FROM internships) AND
             meetings.activity_id NOT IN (SELECT meeting_id FROM online_asynchronous_meetings) AND
             meetings.activity_id NOT IN (SELECT meeting_id FROM online_synchronous_meetings) AND
             meetings.activity_id NOT IN (SELECT meeting_id FROM on_site_meetings)
        THEN 'internship'

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
    rooms.place_limit - studies.place_limit AS free_listener_place_limit,
    products.price AS free_listener_price
FROM study_meetings
    JOIN activities ON study_meetings.meeting_id = activities.id
    JOIN study_modules ON study_meetings.module_id = study_modules.activity_id
    JOIN studies ON study_modules.study_id = studies.activity_id
    JOIN meetings ON study_meetings.meeting_id = meetings.activity_id
    LEFT JOIN meeting_schedule ON meetings.activity_id = meeting_schedule.meeting_id
    LEFT JOIN products ON study_meetings.meeting_id = products.activity_id
    LEFT JOIN on_site_meetings ON meetings.activity_id = on_site_meetings.meeting_id
    LEFT JOIN rooms ON on_site_meetings.room_id = rooms.id

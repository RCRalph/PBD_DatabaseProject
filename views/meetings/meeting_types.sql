CREATE VIEW meeting_types AS
SELECT
    meetings.activity_id AS meeting_id,
    CASE
        WHEN meetings.activity_id IN (SELECT meeting_id FROM study_meeting_information)
        THEN 'study_' + (SELECT meeting_type FROM study_meeting_information WHERE meeting_id = meetings.activity_id)

        WHEN meetings.activity_id IN (SELECT meeting_id FROM course_meeting_information)
        THEN 'course_' + (SELECT meeting_type FROM course_meeting_information WHERE meeting_id = meetings.activity_id)

        WHEN meetings.activity_id IN (SELECT webinar_id FROM webinar_information WHERE webinar_id = meetings.activity_id)
        THEN 'webinar'
    END AS meeting_type
FROM meetings

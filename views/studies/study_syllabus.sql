CREATE VIEW study_syllabus AS
SELECT
    study_modules.study_id AS study_id,
    study_modules.activity_id AS module_id,
    activities.title AS title,
    activities.description AS description,
    COUNT(*) AS meeting_count,
    MIN(meeting_schedule.start_time) AS start_time,
    MAX(meeting_schedule.end_time) AS end_time
FROM study_modules
    JOIN activities ON study_modules.activity_id = activities.id
    JOIN study_meetings ON study_modules.activity_id = study_meetings.module_id
    JOIN meetings ON study_meetings.meeting_id = meetings.activity_id
    LEFT JOIN meeting_schedule ON meetings.activity_id = meeting_schedule.meeting_id
GROUP BY study_modules.study_id, study_modules.activity_id, activities.title, activities.description

CREATE VIEW study_information AS
SELECT
    studies.activity_id AS study_id,
    FORMAT(MIN(study_syllabus.start_time), 'yyyy-MM-dd') AS start_day,
    FORMAT(MAX(study_syllabus.end_time), 'yyyy-MM-dd') AS end_day,
    (
        SELECT COUNT(*)
        FROM study_modules
        WHERE study_modules.study_id = studies.activity_id
    ) AS module_count,
    (
        SELECT COUNT(*)
        FROM study_sessions
        WHERE study_sessions.study_id = studies.activity_id
    ) AS session_count,
    (
        SELECT COUNT(*)
        FROM study_meeting_information
            JOIN study_modules ON study_meeting_information.module_id = study_modules.activity_id
        WHERE study_modules.study_id = studies.activity_id AND study_meeting_information.meeting_type <> 'internship'
    ) AS meeting_count,
    (
        SELECT COUNT(*)
        FROM study_meeting_information
            JOIN study_modules ON study_meeting_information.module_id = study_modules.activity_id
        WHERE study_modules.study_id = studies.activity_id AND study_meeting_information.meeting_type = 'internship'
    ) AS internship_count,
    dbo.get_study_language(studies.activity_id) AS language,
    studies.place_limit AS place_limit,
    products.price AS entry_fee
FROM studies
    JOIN products ON studies.activity_id = products.activity_id
    JOIN study_syllabus ON studies.activity_id = study_syllabus.study_id
GROUP BY studies.activity_id, studies.place_limit, products.price

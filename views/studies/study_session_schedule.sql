CREATE VIEW study_session_schedule AS
SELECT
    study_meeting_information.study_id,
    study_meeting_information.session_id,
    MIN(study_meeting_information.start_time) AS start_time,
    MAX(study_meeting_information.end_time) AS end_time
FROM study_meeting_information
GROUP BY study_meeting_information.study_id, study_meeting_information.session_id

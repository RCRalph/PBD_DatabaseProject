CREATE VIEW study_offers AS
SELECT
    study_information.study_id AS study_id,
    activities.title,
    activities.description,
    study_information.start_day,
    study_information.end_day,
    study_information.module_count,
    study_information.session_count,
    study_information.meeting_count,
    study_information.internship_count,
    study_information.language,
    study_information.place_limit,
    study_information.entry_fee
FROM study_information
    JOIN activities ON study_information.study_id = activities.id

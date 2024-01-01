CREATE VIEW study_meeting_languages AS
SELECT
    study_meetings.module_id,
    study_meetings.session_id,
    study_meetings.meeting_id,
    meeting_translators.language_id,
    meeting_translators.translator_id
FROM study_meetings
    LEFT JOIN meeting_translators ON study_meetings.meeting_id = meeting_translators.meeting_id

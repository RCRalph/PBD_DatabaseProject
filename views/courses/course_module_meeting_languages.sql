CREATE VIEW course_module_meeting_languages AS
SELECT
    module_meetings.module_id,
    module_meetings.meeting_id,
    meeting_translators.language_id,
    meeting_translators.translator_id
FROM module_meetings
    LEFT JOIN meeting_translators ON module_meetings.meeting_id = meeting_translators.meeting_id

CREATE FUNCTION meetings_translated_by_translator(@translator_id INT)
RETURNS @result TABLE (
    title NVARCHAR(128) NOT NULL,
    description NVARCHAR(MAX) NULL,
    language NVARCHAR(64) NOT NULL,
    start_time DATETIME NULL,
    end_time DATETIME NULL
)
BEGIN
    INSERT INTO @result
    SELECT
        activities.title,
        activities.description,
        languages.name,
        meeting_schedule.start_time,
        meeting_schedule.end_time
    FROM meeting_schedule
        JOIN meeting_translators ON meeting_schedule.meeting_id = meeting_translators.meeting_id
        JOIN languages ON meeting_translators.language_id = languages.id
        JOIN activities ON meeting_schedule.meeting_id = activities.id
    WHERE meeting_translators.translator_id = @translator_id;

    RETURN
END

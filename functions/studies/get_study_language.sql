CREATE FUNCTION get_study_language(@study_id INT)
RETURNS NVARCHAR(max)
BEGIN
    DECLARE @result NVARCHAR(max) = '';

    DECLARE study_meetings_cursor CURSOR FOR
        SELECT DISTINCT ISNULL(languages.name, 'Polski') AS language
        FROM study_meeting_languages
            JOIN study_modules ON study_meeting_languages.module_id = study_modules.activity_id
            LEFT JOIN languages ON study_meeting_languages.language_id = languages.id
        WHERE study_modules.study_id = @study_id
        ORDER BY language;

    DECLARE @language NVARCHAR(64);
    OPEN study_meetings_cursor;
    FETCH NEXT FROM study_meetings_cursor INTO @language;

    WHILE @@FETCH_STATUS = 0
        BEGIN
            IF (@result = '')
                SET @result = @language;
            ELSE
                SET @result = CONCAT(@result, ', ', @language);

            FETCH NEXT FROM study_meetings_cursor INTO @language;
        END

    CLOSE study_meetings_cursor;
    DEALLOCATE study_meetings_cursor;

    RETURN @result;
END

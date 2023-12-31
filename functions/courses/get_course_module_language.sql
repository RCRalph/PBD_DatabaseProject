CREATE FUNCTION get_course_module_language(
    @module_id INT
)
RETURNS NVARCHAR(max)
BEGIN
    IF @module_id NOT IN (SELECT activity_id FROM courses)
        THROW 50000, 'Course module not found', 11;

    DECLARE @result NVARCHAR(max) = '';

    DECLARE module_meetings_cursor CURSOR FOR
        SELECT DISTINCT ISNULL(languages.name, 'Polski') AS language
        FROM course_module_meeting_languages
            LEFT JOIN languages ON course_module_meeting_languages.language_id = languages.id
        WHERE module_id = @module_id
        ORDER BY language;

    DECLARE @language NVARCHAR(64);
    OPEN module_meetings_cursor;
    FETCH NEXT FROM module_meetings_cursor INTO @language;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF (@result = '')
            SET @result = @language;
        ELSE
            SET @result = CONCAT(@result, ', ', @language);

        FETCH NEXT FROM module_meetings_cursor INTO @language;
    END

    CLOSE module_meetings_cursor;
    DEALLOCATE module_meetings_cursor;

    RETURN @result;
END

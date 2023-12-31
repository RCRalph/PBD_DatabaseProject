CREATE FUNCTION get_course_language(
    @course_id INT
)
    RETURNS NVARCHAR(max)
BEGIN
    IF @course_id NOT IN (SELECT activity_id FROM courses)
        THROW 50000, 'Course not found', 11;

    DECLARE @result NVARCHAR(max) = '';

    DECLARE module_meetings_cursor CURSOR FOR
        SELECT DISTINCT ISNULL(languages.name, 'Polski') AS language
        FROM course_module_meeting_languages
            JOIN course_modules ON course_module_meeting_languages.module_id = course_modules.activity_id
            LEFT JOIN languages ON course_module_meeting_languages.language_id = languages.id
        WHERE course_id = @course_id
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

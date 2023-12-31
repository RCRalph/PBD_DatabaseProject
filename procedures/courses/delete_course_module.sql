CREATE PROCEDURE delete_course_module
    @module_id INT
AS BEGIN
    IF @module_id NOT IN (SELECT activity_id FROM course_modules)
        THROW 50000, 'Module not found', 11;

    DECLARE @meeting_id INT;
    DECLARE meeting_cursor CURSOR FOR
        SELECT meeting_id
        FROM module_meetings
        WHERE module_id = @module_id;

    OPEN meeting_cursor;
    FETCH NEXT FROM meeting_cursor INTO @meeting_id;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.delete_course_module_meeting @meeting_id;

        FETCH NEXT FROM meeting_cursor INTO @meeting_id;
    END

    DELETE course_modules
    WHERE activity_id = @module_id;

    CLOSE meeting_cursor;
    DEALLOCATE meeting_cursor;
END

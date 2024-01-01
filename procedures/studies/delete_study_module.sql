CREATE PROCEDURE delete_study_module
    @module_id INT
AS BEGIN
    IF @module_id NOT IN (SELECT activity_id FROM study_modules)
        THROW 50000, 'Module not found', 11;

    DECLARE @meeting_id INT;
    DECLARE meeting_cursor CURSOR FOR
        SELECT study_meetings.meeting_id
        FROM study_meetings
        WHERE study_meetings.module_id = @module_id;

    OPEN meeting_cursor;
    FETCH NEXT FROM meeting_cursor INTO @meeting_id;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.delete_study_meeting @meeting_id;

        FETCH NEXT FROM meeting_cursor INTO @meeting_id;
    END

    DELETE study_modules
    WHERE activity_id = @module_id;

    CLOSE meeting_cursor;
    DEALLOCATE meeting_cursor;
END

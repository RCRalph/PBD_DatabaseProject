CREATE PROCEDURE delete_study_session
    @session_id INT
AS BEGIN
    IF @session_id NOT IN (SELECT activity_id FROM study_sessions)
        THROW 50000, 'Session not found', 11;

    DECLARE @meeting_id INT;
    DECLARE meeting_cursor CURSOR FOR
        SELECT study_meetings.meeting_id
        FROM study_meetings
        WHERE study_meetings.session_id = @session_id;

    OPEN meeting_cursor;
    FETCH NEXT FROM meeting_cursor INTO @meeting_id;

    WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC dbo.delete_study_meeting @meeting_id;

            FETCH NEXT FROM meeting_cursor INTO @meeting_id;
        END

    CLOSE meeting_cursor;
    DEALLOCATE meeting_cursor;

    DELETE study_sessions
    WHERE activity_id = @session_id;

    UPDATE products
    SET active = 0
    WHERE activity_id = @session_id;
END

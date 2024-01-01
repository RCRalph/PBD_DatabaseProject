CREATE PROCEDURE delete_study
    @study_id INT
AS BEGIN
    IF @study_id NOT IN (SELECT activity_id FROM studies)
        THROW 50000, 'Study not found', 11;

    DECLARE @session_id INT;
    DECLARE session_cursor CURSOR FOR
        SELECT study_sessions.activity_id
        FROM study_sessions
        WHERE study_sessions.study_id = @study_id;

    OPEN session_cursor;
    FETCH NEXT FROM session_cursor INTO @session_id;

    WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC dbo.delete_study_session @session_id;

            FETCH NEXT FROM session_cursor INTO @session_id;
        END

    CLOSE session_cursor;
    DEALLOCATE session_cursor;

    DECLARE @module_id INT;
    DECLARE module_cursor CURSOR FOR
        SELECT study_modules.activity_id
        FROM study_modules
        WHERE study_modules.study_id = @study_id;

    OPEN module_cursor;
    FETCH NEXT FROM module_cursor INTO @module_id;

    WHILE @@FETCH_STATUS = 0
        BEGIN
            EXEC dbo.delete_study_module @module_id;

            FETCH NEXT FROM module_cursor INTO @module_id;
        END

    CLOSE module_cursor;
    DEALLOCATE module_cursor;

    UPDATE products
    SET active = 0
    WHERE activity_id = @study_id;

    DELETE studies
    WHERE activity_id = @study_id;
END

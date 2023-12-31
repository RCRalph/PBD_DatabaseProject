CREATE PROCEDURE delete_course
    @course_id INT
AS BEGIN
    IF @course_id NOT IN (SELECT activity_id FROM courses)
        THROW 50000, 'Course not found', 11;

    DECLARE @module_id INT;
    DECLARE module_cursor CURSOR FOR
        SELECT activity_id
        FROM course_modules
        WHERE course_id = @course_id;

    OPEN module_cursor;
    FETCH NEXT FROM module_cursor INTO @module_id;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        EXEC dbo.delete_course_module @module_id;

        FETCH NEXT FROM module_cursor INTO @module_id;
    END

    UPDATE products
    SET active = 0
    WHERE activity_id = @course_id;

    DELETE courses
    WHERE activity_id = @course_id;

    CLOSE module_cursor;
    DEALLOCATE module_cursor;
END

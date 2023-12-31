CREATE PROCEDURE create_course_module
    @course_id INT,
    @title NVARCHAR(128),
    @description NVARCHAR(MAX),
    @module_id INT OUTPUT
AS BEGIN
    IF @course_id NOT IN (SELECT activity_id FROM courses)
        THROW 50000, 'Course not found', 11;

    DECLARE @inserted_activity TABLE (id INT);

    INSERT INTO activities (title, description)
    OUTPUT INSERTED.id INTO @inserted_activity
    VALUES (@title, @description);

    SELECT @module_id = id FROM @inserted_activity;

    INSERT INTO course_modules (activity_id, course_id)
    VALUES (@module_id, @course_id);
END

CREATE PROCEDURE create_course
    @title NVARCHAR(128),
    @description NVARCHAR(MAX),
    @coordinator_id INT,
    @price MONEY,
    @course_id INT OUTPUT
AS BEGIN
    IF @coordinator_id NOT IN (SELECT user_id FROM coordinators)
        THROW 50000, 'Coordinator not found', 11;
    ELSE IF @price < 0
        THROW 50001, 'Price cannot be negative', 16;

    DECLARE @inserted_activity TABLE (id INT);

    INSERT INTO activities (title, description)
    OUTPUT INSERTED.id INTO @inserted_activity
    VALUES (@title, @description);

    SELECT @course_id = id FROM @inserted_activity;

    INSERT INTO courses (activity_id, coordinator_id)
    VALUES (@course_id, @coordinator_id);

    INSERT INTO products (activity_id, price)
    VALUES (@course_id, @price);
END

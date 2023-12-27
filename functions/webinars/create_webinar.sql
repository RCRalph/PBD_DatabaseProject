CREATE FUNCTION create_webinar(
    @title NVARCHAR(128),
    @description NVARCHAR(MAX),
    @tutor_id INT,
    @online_platform_id INT,
    @start_time DATETIME,
    @end_time DATETIME,
    @price MONEY
) RETURNS INT
AS BEGIN
    IF @tutor_id NOT IN (SELECT user_id FROM tutors)
        THROW 50000, 'Tutor not found', 11;
    ELSE IF @online_platform_id NOT IN (SELECT id FROM online_platforms)
        THROW 50001, 'Online platform not found', 11;
    ELSE IF @start_time > @end_time
        THROW 50002, 'Start time must be before end time', 16;
    ELSE IF @price < 0
        THROW 50003, 'Price cannot be negative', 16;

    INSERT INTO activities (title, description)
    VALUES (@title, @description);

    DECLARE @activity_id INT = (SELECT @@IDENTITY);

    INSERT INTO meetings (activity_id, tutor_id)
    VALUES (@activity_id, @tutor_id);

    INSERT INTO online_synchronous_meetings (meeting_id, platform_id)
    VALUES (@activity_id, @online_platform_id);

    INSERT INTO meeting_schedule (meeting_id, start_time, end_time)
    VALUES (@activity_id, @start_time, @end_time);

    INSERT INTO products (activity_id, price)
    VALUES (@activity_id, @price);

    RETURN @activity_id;
END

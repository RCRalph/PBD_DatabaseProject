CREATE PROCEDURE create_course_module_on_site_meeting
    @module_id INT,
    @title NVARCHAR(128),
    @description NVARCHAR(MAX),
    @tutor_id INT,
    @room_id INT,
    @start_time DATETIME,
    @end_time DATETIME,
    @activity_id INT OUTPUT
AS BEGIN
    IF @module_id NOT IN (SELECT activity_id FROM course_modules)
        THROW 50000, 'Course module not found', 11;
    ELSE IF @tutor_id NOT IN (SELECT user_id FROM tutors)
        THROW 50001, 'Tutor not found', 11;
    ELSE IF @room_id NOT IN (SELECT id FROM rooms)
        THROW 50002, 'Room not found', 11;
    ELSE IF @start_time > @end_time
        THROW 50003, 'Start time must be before end time', 16;
    ELSE IF 1 = dbo.intersects_with_schedule(
        @start_time,
        @end_time,
        (
            SELECT start_time, end_time
            FROM course_meetings
            WHERE course_id = (
                SELECT course_modules.course_id
                FROM course_modules
                WHERE course_modules.activity_id = @module_id
            )
        )
    )
        THROW 50004, 'Meeting intersects with other meetings in this course', 16;
    ELSE IF 1 = dbo.intersects_with_schedule(
        @start_time,
        @end_time,
        (
            SELECT start_time, end_time
            FROM room_schedule
            WHERE room_id = @room_id
        )
    )
        THROW 50005, 'Meeting room is already occupied during given time period', 16;

    DECLARE @inserted_activity TABLE (id INT);

    INSERT INTO activities (title, description)
    OUTPUT INSERTED.id INTO @inserted_activity
    VALUES (@title, @description);

    SELECT @activity_id = id FROM @inserted_activity;
    SELECT @activity_id AS activity_id;

    INSERT INTO meetings (activity_id, tutor_id)
    VALUES (@activity_id, @tutor_id);

    INSERT INTO on_site_meetings (meeting_id, room_id)
    VALUES (@activity_id, @room_id);

    INSERT INTO meeting_schedule (meeting_id, start_time, end_time)
    VALUES (@activity_id, @start_time, @end_time);

    INSERT INTO module_meetings (meeting_id, module_id)
    VALUES (@activity_id, @module_id);
END

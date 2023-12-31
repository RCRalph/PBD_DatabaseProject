CREATE PROCEDURE create_course_module_online_synchronous_meeting
    @module_id INT,
    @title NVARCHAR(128),
    @description NVARCHAR(MAX),
    @tutor_id INT,
    @platform_id INT,
    @start_time DATETIME,
    @end_time DATETIME,
    @activity_id INT OUTPUT
AS BEGIN
    IF @module_id NOT IN (SELECT activity_id FROM course_modules)
        THROW 50000, 'Course module not found', 11;
    ELSE IF @tutor_id NOT IN (SELECT user_id FROM tutors)
        THROW 50001, 'Tutor not found', 11;
    ELSE IF @platform_id NOT IN (SELECT id FROM online_platforms)
        THROW 50002, 'Online platform not found', 11;
    ELSE IF @start_time > @end_time
        THROW 50003, 'Start time must be before end time', 16;

    DECLARE @course_schedule SCHEDULE;

    INSERT INTO @course_schedule (start_time, end_time)
    SELECT start_time, end_time
    FROM course_meeting_information
    WHERE course_id = (
        SELECT course_modules.course_id
        FROM course_modules
        WHERE course_modules.activity_id = @module_id
    );

    IF 1 = dbo.intersects_with_schedule(@start_time, @end_time, @course_schedule)
        THROW 50004, 'Meeting intersects with other meetings in this course', 16;

    DECLARE @inserted_activity TABLE (id INT);

    INSERT INTO activities (title, description)
    OUTPUT INSERTED.id INTO @inserted_activity
    VALUES (@title, @description);

    SELECT @activity_id = id FROM @inserted_activity;
    SELECT @activity_id AS activity_id;

    INSERT INTO meetings (activity_id, tutor_id)
    VALUES (@activity_id, @tutor_id);

    INSERT INTO online_synchronous_meetings (meeting_id, platform_id)
    VALUES (@activity_id, @platform_id);

    INSERT INTO meeting_schedule (meeting_id, start_time, end_time)
    VALUES (@activity_id, @start_time, @end_time);

    INSERT INTO module_meetings (meeting_id, module_id)
    VALUES (@activity_id, @module_id);
END

CREATE PROCEDURE create_course_module_online_asynchronous_meeting
    @module_id INT,
    @title NVARCHAR(128),
    @description NVARCHAR(MAX),
    @tutor_id INT,
    @recording_url NVARCHAR(128),
    @meeting_id INT OUTPUT
AS BEGIN
    IF @module_id NOT IN (SELECT activity_id FROM course_modules)
        THROW 50000, 'Course module not found', 11;
    ELSE IF @tutor_id NOT IN (SELECT user_id FROM tutors)
        THROW 50001, 'Tutor not found', 11;
    ELSE IF @recording_url IS NULL
        THROW 50002, 'Recording URL cannot be NULL', 16;
    ELSE IF @recording_url IN (SELECT recording_url FROM online_asynchronous_meetings)
        THROW 50002, 'Recording URL has to be unique', 16;

    DECLARE @inserted_activity TABLE (id INT);

    INSERT INTO activities (title, description)
    OUTPUT INSERTED.id INTO @inserted_activity
    VALUES (@title, @description);

    SELECT @meeting_id = id FROM @inserted_activity;

    INSERT INTO meetings (activity_id, tutor_id)
    VALUES (@meeting_id, @tutor_id);

    INSERT INTO online_asynchronous_meetings (meeting_id, recording_url)
    VALUES (@meeting_id, @recording_url);

    INSERT INTO module_meetings (meeting_id, module_id)
    VALUES (@meeting_id, @module_id);
END

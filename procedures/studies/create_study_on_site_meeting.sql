CREATE PROCEDURE create_study_on_site_meeting
    @module_id INT,
    @session_id INT,
    @title NVARCHAR(128),
    @description NVARCHAR(MAX),
    @tutor_id INT,
    @room_id INT,
    @start_time DATETIME,
    @end_time DATETIME,
    @price MONEY,
    @meeting_id INT OUTPUT
AS BEGIN
    IF @module_id NOT IN (SELECT activity_id FROM study_modules)
        THROW 50000, 'Study module not found', 11;
    ELSE IF @session_id NOT IN (SELECT activity_id FROM study_sessions)
        THROW 50001, 'Study session not found', 11;
    ELSE IF 0 = dbo.study_module_and_session_same_studies(@module_id, @session_id)
        THROW 50002, 'Study session and study module must belong to the same studies', 16;
    ELSE IF dbo.is_study_module_empty(@module_id) = 0 AND dbo.is_internship_module(@module_id) = 1
        THROW 50003, 'Study module cannot be an internship module', 16;
    ELSE IF @tutor_id NOT IN (SELECT user_id FROM tutors)
        THROW 50004, 'Tutor not found', 11;
    ELSE IF @room_id NOT IN (SELECT id FROM rooms)
        THROW 50005, 'Room not found', 11;
    ELSE IF @room_id NOT IN (
        SELECT rooms.id
        FROM rooms
        WHERE rooms.place_limit >= (
            SELECT TOP 1 studies.place_limit
            FROM studies
                JOIN study_modules ON studies.activity_id = study_modules.study_id
            WHERE study_modules.activity_id = @module_id
        )
    )
        THROW 50006, 'Study place limit is greater than room place limit', 16;
    ELSE IF @start_time > @end_time
        THROW 50007, 'Start time must be before end time', 16;
    ELSE IF @price < 0
        THROW 50008, 'Price cannot be negative', 16;

    DECLARE @study_id INT = (
        SELECT study_modules.study_id
        FROM study_modules
        WHERE activity_id = @module_id
    );

    DECLARE @study_schedule SCHEDULE;

    INSERT INTO @study_schedule (start_time, end_time)
    SELECT start_time, end_time
    FROM study_meeting_information
    WHERE study_id = @study_id;

    IF 1 = dbo.intersects_with_schedule(@start_time, @end_time, @study_schedule)
        THROW 50009, 'Meeting intersects with other meetings in the studies', 16;

    DECLARE @session_schedule SCHEDULE;

    INSERT INTO @session_schedule (start_time, end_time)
    SELECT start_time, end_time
    FROM study_session_schedule
    WHERE study_id = @study_id AND session_id <> @session_id;

    IF 1 = dbo.intersects_with_schedule(@start_time, @end_time, @session_schedule)
        THROW 50010, 'Meeting session intersects with other sessions in in the studies', 16;

    DECLARE @room_schedule SCHEDULE;

    INSERT INTO @room_schedule (start_time, end_time)
    SELECT start_time, end_time
    FROM room_schedule
    WHERE room_id = @room_id;

    IF 1 = dbo.intersects_with_schedule(@start_time, @end_time, @room_schedule)
        THROW 50011, 'Meeting room is already occupied during given time period', 16;

    DECLARE @inserted_activity TABLE (id INT);

    INSERT INTO activities (title, description)
    OUTPUT INSERTED.id INTO @inserted_activity
    VALUES (@title, @description);

    SELECT @meeting_id = id FROM @inserted_activity;

    INSERT INTO meetings (activity_id, tutor_id)
    VALUES (@meeting_id, @tutor_id);

    INSERT INTO on_site_meetings (meeting_id, room_id)
    VALUES (@meeting_id, @room_id);

    INSERT INTO meeting_schedule (meeting_id, start_time, end_time)
    VALUES (@meeting_id, @start_time, @end_time);

    INSERT INTO study_meetings (meeting_id, module_id, session_id)
    VALUES (@meeting_id, @module_id, @session_id);

    INSERT INTO products (activity_id, price)
    VALUES (@meeting_id, @price);
END

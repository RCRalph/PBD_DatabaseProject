CREATE PROCEDURE create_study_online_asynchronous_meeting
    @module_id INT,
    @session_id INT,
    @title NVARCHAR(128),
    @description NVARCHAR(MAX),
    @tutor_id INT,
    @recording_url NVARCHAR(128),
    @price MONEY,
    @meeting_id INT OUTPUT
AS BEGIN
    IF @module_id NOT IN (SELECT activity_id FROM study_modules)
        THROW 50000, 'Study module not found', 11;
    ELSE IF @session_id NOT IN (SELECT activity_id FROM study_sessions)
        THROW 50001, 'Study session not found', 11;
    ELSE IF 0 = dbo.study_module_and_session_same_studies(@module_id, @session_id)
        THROW 50002, 'Study session and study module must belong to the same studies', 16;
    ELSE IF 1 = dbo.is_internship_module(@module_id)
        THROW 50003, 'Study module cannot be an internship module', 16;
    ELSE IF @tutor_id NOT IN (SELECT user_id FROM tutors)
        THROW 50004, 'Tutor not found', 11;
    ELSE IF @recording_url IS NULL
        THROW 50005, 'Recording URL cannot be NULL', 16;
    ELSE IF @recording_url IN (SELECT recording_url FROM online_asynchronous_meetings)
        THROW 50006, 'Recording URL has to be unique', 16;
    ELSE IF @price < 0
        THROW 50007, 'Price cannot be negative', 16;

    DECLARE @inserted_activity TABLE (id INT);

    INSERT INTO activities (title, description)
    OUTPUT INSERTED.id INTO @inserted_activity
    VALUES (@title, @description);

    SELECT @meeting_id = id FROM @inserted_activity;

    INSERT INTO meetings (activity_id, tutor_id)
    VALUES (@meeting_id, @tutor_id);

    INSERT INTO online_asynchronous_meetings (meeting_id, recording_url)
    VALUES (@meeting_id, @recording_url);

    INSERT INTO study_meetings (meeting_id, module_id, session_id)
    VALUES (@meeting_id, @module_id, @session_id);

    INSERT INTO products (activity_id, price)
    VALUES (@meeting_id, @price);
END

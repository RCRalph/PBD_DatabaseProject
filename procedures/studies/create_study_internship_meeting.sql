CREATE PROCEDURE create_study_internship_meeting
    @module_id INT,
    @session_id INT,
    @title NVARCHAR(128),
    @description NVARCHAR(MAX),
    @tutor_id INT,
    @start_time DATETIME,
    @end_time DATETIME,
    @meeting_id INT OUTPUT
AS BEGIN
    IF @module_id NOT IN (SELECT activity_id FROM study_modules)
        THROW 50000, 'Study module not found', 11;
    ELSE IF @session_id NOT IN (SELECT activity_id FROM study_sessions)
        THROW 50001, 'Study session not found', 11;
    ELSE IF 0 = dbo.study_module_and_session_same_studies(@module_id, @session_id)
        THROW 50002, 'Study session and study module must belong to the same studies', 16;
    ELSE IF 0 = dbo.is_internship_module(@module_id)
        THROW 50003, 'Study module must be an internship module', 16;
    ELSE IF @tutor_id NOT IN (SELECT user_id FROM tutors)
        THROW 50004, 'Tutor not found', 11;
    ELSE IF @start_time > @end_time
        THROW 50005, 'Start time must be before end time', 16;

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
        THROW 50006, 'Meeting intersects with other meetings in the studies', 16;

    DECLARE @session_schedule SCHEDULE;

    INSERT INTO @session_schedule (start_time, end_time)
    SELECT start_time, end_time
    FROM study_session_schedule
    WHERE study_id = @study_id AND session_id <> @session_id;

    IF 1 = dbo.intersects_with_schedule(@start_time, @end_time, @session_schedule)
        THROW 50007, 'Meeting session intersects with other sessions in in the studies', 16;

    DECLARE @inserted_activity TABLE (id INT);

    INSERT INTO activities (title, description)
    OUTPUT INSERTED.id INTO @inserted_activity
    VALUES (@title, @description);

    SELECT @meeting_id = id FROM @inserted_activity;

    INSERT INTO meetings (activity_id, tutor_id)
    VALUES (@meeting_id, @tutor_id);

    INSERT INTO internships (meeting_id)
    VALUES (@meeting_id);

    INSERT INTO meeting_schedule (meeting_id, start_time, end_time)
    VALUES (@meeting_id, @start_time, @end_time);

    INSERT INTO study_meetings (meeting_id, module_id, session_id)
    VALUES (@meeting_id, @module_id, @session_id);
END

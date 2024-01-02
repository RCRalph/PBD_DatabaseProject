CREATE PROCEDURE update_study_meeting_schedule
    @meeting_id INT,
    @start_time DATETIME,
    @end_time DATETIME
AS BEGIN
    IF @meeting_id NOT IN (
        SELECT meeting_id
        FROM study_meeting_information
        WHERE meeting_type IN ('online_synchronous', 'on_site', 'internship')
    )
        THROW 50000, 'Meeting not found', 11;
    ELSE IF @start_time > @end_time
        THROW 50001, 'Start time must be before end time', 16;

    DECLARE @session_id INT = (SELECT session_id FROM study_meetings WHERE meeting_id = @meeting_id);
    DECLARE @study_id INT = (SELECT study_sessions.study_id FROM study_sessions WHERE activity_id = @session_id);

    DECLARE @study_schedule SCHEDULE;

    INSERT INTO @study_schedule (start_time, end_time)
    SELECT start_time, end_time
    FROM study_meeting_information
    WHERE study_id = @study_id;

    IF 1 = dbo.intersects_with_schedule(@start_time, @end_time, @study_schedule)
        THROW 50002, 'Meeting intersects with other meetings in the studies', 16;

    DECLARE @session_schedule SCHEDULE;

    INSERT INTO @session_schedule (start_time, end_time)
    SELECT start_time, end_time
    FROM study_session_schedule
    WHERE study_id = @study_id AND session_id <> @session_id;

    IF 1 = dbo.intersects_with_schedule(@start_time, @end_time, @session_schedule)
        THROW 50003, 'Meeting session intersects with other sessions in in the studies', 16;

    IF @meeting_id IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'on_site')
    BEGIN
        DECLARE @room_schedule SCHEDULE;

        INSERT INTO @room_schedule (start_time, end_time)
        SELECT start_time, end_time
        FROM room_schedule
        WHERE room_id = (
            SELECT on_site_meetings.room_id
            FROM on_site_meetings
            WHERE meeting_id = @meeting_id
        );

        IF 1 = dbo.intersects_with_schedule(@start_time, @end_time, @room_schedule)
            THROW 50004, 'Meeting room is already occupied during given time period', 16;
    END

    UPDATE meeting_schedule
    SET start_time = @start_time, end_time = @end_time
    WHERE meeting_id = @meeting_id;
END

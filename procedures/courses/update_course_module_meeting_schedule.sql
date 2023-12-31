CREATE PROCEDURE update_course_module_meeting_schedule
    @meeting_id INT,
    @start_time DATETIME,
    @end_time DATETIME
AS BEGIN
    IF @meeting_id NOT IN (
        SELECT meeting_id
        FROM course_meeting_information
        WHERE meeting_type IN ('online_synchronous', 'on_site')
    )
        THROW 50000, 'Meeting not found', 11;
    ELSE IF @start_time > @end_time
        THROW 50001, 'Start time must be before end time', 16;

    DECLARE @course_schedule SCHEDULE;

    INSERT INTO @course_schedule (start_time, end_time)
    SELECT start_time, end_time
    FROM course_meeting_information
    WHERE course_id = (
        SELECT course_meeting_information.course_id
        FROM course_meeting_information
        WHERE course_meeting_information.meeting_id = @meeting_id
    );

    IF 1 = dbo.intersects_with_schedule(@start_time, @end_time, @course_schedule)
        THROW 50002, 'Schedule intersects with other meetings in this course', 16;

    IF @meeting_id IN (SELECT meeting_id FROM course_meeting_information WHERE meeting_type = 'on_site')
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
            THROW 50003, 'Meeting room is already occupied during given time period', 16;
    END

    UPDATE meeting_schedule
    SET start_time = @start_time, end_time = @end_time
    WHERE meeting_id = @meeting_id;
END

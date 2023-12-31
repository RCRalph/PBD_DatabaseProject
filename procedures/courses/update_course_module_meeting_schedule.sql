CREATE PROCEDURE update_course_module_meeting_schedule
    @meeting_id INT,
    @start_time DATETIME,
    @end_time DATETIME
AS BEGIN
    IF @meeting_id NOT IN (SELECT meeting_id FROM course_meetings WHERE meeting_type IN ('online_synchronous', 'on_site'))
        THROW 50000, 'Meeting not found', 11;
    ELSE IF @start_time > @end_time
        THROW 50001, 'Start time must be before end time', 16;
    ELSE IF 1 = dbo.intersects_with_schedule(
        @start_time,
        @end_time,
        (
            SELECT start_time, end_time
            FROM course_meetings
            WHERE course_id = (
                SELECT course_meetings.course_id
                FROM course_meetings
                WHERE course_meetings.meeting_id = @meeting_id
            )
        )
    )
        THROW 50002, 'Schedule intersects with other meetings in this course', 16;
    ELSE IF @meeting_id IN (
        SELECT meeting_id
        FROM course_meetings
        WHERE meeting_type = 'on_site'
    ) AND 1 = dbo.intersects_with_schedule(
        @start_time,
        @end_time,
        (
            SELECT start_time, end_time
            FROM room_schedule
            WHERE room_id = (
                SELECT on_site_meetings.room_id
                FROM on_site_meetings
                WHERE meeting_id = @meeting_id
            )
        )
    )
        THROW 50003, 'Meeting room is already occupied during given time period', 16;

    UPDATE meeting_schedule
    SET start_time = @start_time, end_time = @end_time
    WHERE meeting_id = @meeting_id;
END

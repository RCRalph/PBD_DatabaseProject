CREATE PROCEDURE update_webinar_schedule
    @webinar_id INT,
    @start_time DATETIME,
    @end_time DATETIME
AS BEGIN
    IF @webinar_id NOT IN (SELECT webinar_id FROM webinar_information)
        THROW 50000, 'Webinar not found', 11;
    ELSE IF @start_time > @end_time
        THROW 50001, 'Start time must be before end time', 16;

    UPDATE meeting_schedule
    SET start_time = @start_time, end_time = @end_time
    WHERE meeting_id = @webinar_id;
END

CREATE PROCEDURE update_webinar_meeting_url
    @webinar_id INT,
    @meeting_url NVARCHAR(128)
AS BEGIN
    IF @webinar_id NOT IN (SELECT webinar_id FROM webinars)
        THROW 50000, 'Webinar not found', 11;
    ELSE IF @meeting_url IN (SELECT meeting_url FROM webinars)
        THROW 50001, 'Meeting URL has to be unique', 16;
    ELSE IF @meeting_url IS NULL
        THROW 50002, 'Cannot update meeting URL to NULL', 16;

    UPDATE online_synchronous_meetings
    SET meeting_url = @meeting_url
    WHERE meeting_id = @webinar_id;
END

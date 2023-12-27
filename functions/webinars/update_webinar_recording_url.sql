CREATE PROCEDURE update_webinar_recording_url
    @webinar_id INT,
    @recording_url NVARCHAR(128)
AS BEGIN
    IF @webinar_id NOT IN (SELECT webinar_id FROM webinar_information)
        THROW 50000, 'Webinar not found', 11;
    ELSE IF @recording_url IN (SELECT recording_url FROM webinar_information)
        THROW 50001, 'Recording URL has to be unique', 16;
    ELSE IF @recording_url IS NULL
        THROW 50002, 'Cannot update recording URL to NULL', 16;
    ELSE IF GETDATE() < (SELECT end_time FROM webinar_information WHERE webinar_id = @webinar_id)
        THROW 50003, 'Cannot set recording URL before the webinar ends', 16;

    UPDATE online_synchronous_meetings
    SET recording_url = @recording_url
    WHERE meeting_id = @webinar_id;
END

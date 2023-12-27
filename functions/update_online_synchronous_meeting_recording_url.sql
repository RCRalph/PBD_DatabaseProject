CREATE PROCEDURE update_online_synchronous_meeting_recording_url
    @meeting_id INT,
    @recording_url NVARCHAR(128)
AS BEGIN
    IF @meeting_id NOT IN (SELECT meeting_id FROM online_synchronous_meetings)
        THROW 50000, 'Meeting not found', 11;
    ELSE IF @recording_url IN (SELECT meeting_url FROM online_synchronous_meetings)
        THROW 50001, 'Meeting URL has to be unique', 16;
    ELSE IF @recording_url IS NULL
        THROW 50002, 'Cannot update meeting URL to NULL', 16;
    ELSE IF GETDATE() < (SELECT end_time FROM meeting_schedule WHERE meeting_id = @meeting_id)
        THROW 50003, 'Cannot set recording URL before the meeting ends', 16;

    UPDATE online_synchronous_meetings
    SET recording_url = @recording_url
    WHERE meeting_id = @meeting_id;
END

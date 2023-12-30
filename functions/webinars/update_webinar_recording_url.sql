CREATE PROCEDURE update_webinar_recording_url
    @webinar_id INT,
    @recording_url NVARCHAR(128)
AS BEGIN
    IF @webinar_id NOT IN (SELECT webinar_id FROM webinar_information)
        THROW 50000, 'Webinar not found', 11;

    EXEC dbo.update_online_synchronous_meeting_recording_url @webinar_id, @recording_url;
END

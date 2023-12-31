CREATE PROCEDURE update_webinar_meeting_url
    @webinar_id INT,
    @meeting_url NVARCHAR(128)
AS BEGIN
    IF @webinar_id NOT IN (SELECT webinar_id FROM webinar_information)
        THROW 50000, 'Webinar not found', 11;

    EXEC dbo.update_online_synchronous_meeting_url @webinar_id, @meeting_url;
END

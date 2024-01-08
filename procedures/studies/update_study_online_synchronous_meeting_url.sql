CREATE PROCEDURE update_study_module_online_synchronous_meeting_url
    @meeting_id INT,
    @meeting_url NVARCHAR(128)
AS BEGIN
    IF @meeting_id NOT IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'online_synchronous')
        THROW 50000, 'Meeting not found', 11;

    EXEC dbo.update_online_synchronous_meeting_url @meeting_id, @meeting_url;
END

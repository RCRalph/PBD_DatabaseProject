CREATE PROCEDURE update_course_module_online_synchronous_meeting_recording_url
    @meeting_id INT,
    @recording_url NVARCHAR(128)
AS BEGIN
    IF @meeting_id NOT IN (SELECT meeting_id FROM course_meetings WHERE meeting_type = 'online_synchronous')
        THROW 50000, 'Meeting not found', 11;

    EXEC dbo.update_online_synchronous_meeting_recording_url @meeting_id, @recording_url;
END

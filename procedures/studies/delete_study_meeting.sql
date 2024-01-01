CREATE PROCEDURE delete_study_meeting
    @meeting_id INT
AS BEGIN
    IF @meeting_id NOT IN (SELECT meeting_id FROM study_meeting_information)
        THROW 50000, 'Meeting not found', 11;

    DELETE on_site_meetings WHERE meeting_id = @meeting_id;
    DELETE online_asynchronous_meetings WHERE meeting_id = @meeting_id;
    DELETE online_synchronous_meetings WHERE meeting_id = @meeting_id;
    DELETE meeting_schedule WHERE meeting_id = @meeting_id;
    DELETE meeting_translators WHERE meeting_id = @meeting_id;
    DELETE study_meetings WHERE meeting_id = @meeting_id;
    DELETE meetings WHERE activity_id = @meeting_id;
END

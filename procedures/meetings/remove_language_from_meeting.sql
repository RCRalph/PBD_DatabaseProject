CREATE PROCEDURE remove_language_from_meeting
    @meeting_id INT
AS BEGIN
    IF @meeting_id NOT IN (SELECT activity_id FROM meetings)
        THROW 50000, 'Meeting not found', 11;

    DELETE meeting_translators
    WHERE meeting_id = @meeting_id;
END

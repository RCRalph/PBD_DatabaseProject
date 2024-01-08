CREATE FUNCTION meetings_conducted_by_tutor(@tutor_id INT)
RETURNS @result TABLE (
    title NVARCHAR(128) NOT NULL,
    description NVARCHAR(MAX) NULL,
    start_time DATETIME NULL,
    end_time DATETIME NULL
)
BEGIN
    INSERT INTO @result
    SELECT
        activities.title,
        activities.description,
        meeting_schedule.start_time,
        meeting_schedule.end_time
    FROM meeting_schedule
        JOIN meetings ON meeting_schedule.meeting_id = meetings.activity_id
        JOIN activities ON meetings.activity_id = activities.id
    WHERE meetings.tutor_id = @tutor_id;

    RETURN
END

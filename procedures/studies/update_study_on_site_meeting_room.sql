CREATE PROCEDURE update_study_on_site_meeting_room
    @meeting_id INT,
    @room_id INT
AS BEGIN
    IF @meeting_id NOT IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'on_site')
        THROW 50000, 'Meeting not found', 11;
    ELSE IF @room_id NOT IN (SELECT id FROM rooms)
        THROW 50001, 'Room not found', 11;
    ELSE IF @room_id NOT IN (
        SELECT rooms.id
        FROM rooms
        WHERE rooms.place_limit >= (
            SELECT studies.place_limit
            FROM studies
                JOIN study_modules ON studies.activity_id = study_modules.study_id
                JOIN study_meetings ON study_modules.activity_id = study_meetings.module_id
            WHERE study_meetings.meeting_id = @meeting_id
        )
    )
        THROW 50002, 'Study place limit is greater than room place limit', 16;

    DECLARE @room_schedule SCHEDULE;

    INSERT INTO @room_schedule
    SELECT start_time, end_time
    FROM room_schedule
    WHERE room_id = @room_id;

    IF 1 = dbo.intersects_with_schedule(
        (SELECT start_time FROM meeting_schedule WHERE meeting_id = @meeting_id),
        (SELECT end_time FROM meeting_schedule WHERE meeting_id = @meeting_id),
        @room_schedule
    )
        THROW 50002, 'Meeting room is already occupied during given time period', 16;

    UPDATE on_site_meetings
    SET room_id = @room_id
    WHERE meeting_id = @meeting_id;
END

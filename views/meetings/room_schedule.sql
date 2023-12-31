CREATE VIEW room_schedule AS
SELECT
    rooms.id AS room_id,
    meeting_schedule.start_time AS start_time,
    meeting_schedule.end_time AS end_time
FROM rooms
    JOIN on_site_meetings on rooms.id = on_site_meetings.room_id
    JOIN meeting_schedule ON on_site_meetings.meeting_id = meeting_schedule.meeting_id

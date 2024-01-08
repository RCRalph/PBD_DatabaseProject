CREATE VIEW attendance_list AS
SELECT
    meeting_participants.meeting_id,
    FORMAT(meeting_schedule.start_time, 'yyyy-MM-dd') AS date,
    users.first_name,
    users.last_name,
    meeting_participants.presence
FROM meeting_participants
    LEFT JOIN users ON meeting_participants.student_id = users.id
    LEFT JOIN meeting_schedule ON meeting_participants.meeting_id = meeting_schedule.meeting_id
WHERE meeting_participants.presence IS NOT NULL

CREATE VIEW future_meeting_attendee_count AS
SELECT
    meeting_participants.meeting_id,
    meeting_types.meeting_type,
    COUNT(*) AS attendee_count
FROM meeting_participants
    JOIN meeting_schedule ON meeting_participants.meeting_id = meeting_schedule.meeting_id
    JOIN meeting_types ON meeting_participants.meeting_id = meeting_types.meeting_id
WHERE meeting_schedule.start_time >= GETDATE()
GROUP BY meeting_participants.meeting_id, meeting_types.meeting_type

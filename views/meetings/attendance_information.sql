CREATE VIEW attendance_information AS
SELECT
    meeting_participants.meeting_id,
    (
        SELECT CAST(COUNT(*) AS FLOAT)
        FROM meeting_participants MP
        WHERE MP.meeting_id = meeting_participants.meeting_id AND
              MP.presence = 1
    ) / COUNT(*) AS presence_fraction
FROM meeting_participants
    JOIN meeting_schedule ON meeting_participants.meeting_id = meeting_schedule.meeting_id
WHERE meeting_schedule.end_time < GETDATE() AND meeting_participants.presence IS NOT NULL
GROUP BY meeting_participants.meeting_id

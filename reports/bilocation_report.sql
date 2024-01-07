CREATE VIEW bilocation_report AS
WITH student_meetings AS (
    SELECT
        product_owners.student_id,
        product_owners.product_id AS meeting_id,
        meeting_schedule.start_time,
        meeting_schedule.end_time
    FROM product_owners
        JOIN meeting_schedule ON product_owners.product_id = meeting_schedule.meeting_id
)

SELECT
    student_meetings.student_id,
    student_meetings.meeting_id AS first_meeting_id,
    student_meetings.start_time AS first_meeting_start_time,
    student_meetings.end_time AS first_meeting_end_time,
    SM.meeting_id AS second_meeting_id,
    SM.start_time AS second_meeting_start_time,
    SM.end_time AS second_meeting_end_time
FROM student_meetings
    JOIN student_meetings SM ON student_meetings.student_id = SM.student_id
WHERE student_meetings.meeting_id < SM.meeting_id AND
      (student_meetings.start_time >= GETDATE() OR SM.start_time >= GETDATE()) AND
      (student_meetings.end_time >= SM.start_time AND student_meetings.start_time <= SM.end_time)

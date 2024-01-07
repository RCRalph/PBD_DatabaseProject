CREATE VIEW course_passes AS
SELECT
    course_modules.course_id,
    meeting_participants.student_id,
    dbo.is_student_passing_course(
        course_modules.course_id,
        meeting_participants.student_id
    ) AS pass
FROM meeting_participants
    LEFT JOIN module_meetings ON meeting_participants.meeting_id = module_meetings.meeting_id
    JOIN course_modules ON module_meetings.module_id = course_modules.activity_id
GROUP BY course_modules.course_id, meeting_participants.student_id

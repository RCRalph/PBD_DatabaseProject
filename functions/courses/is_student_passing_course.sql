CREATE FUNCTION is_student_passing_course(@course_id INT, @student_id INT)
RETURNS BIT
BEGIN
    DECLARE @course_meeting_count INT = (
        SELECT COUNT(*)
        FROM courses
            JOIN course_modules ON courses.activity_id = course_modules.course_id
            JOIN module_meetings ON course_modules.activity_id = module_meetings.module_id
        WHERE courses.activity_id = @course_id
    );

    DECLARE @student_meeting_presence_count INT = (
        SELECT COUNT(*)
        FROM meeting_participants
        WHERE meeting_participants.presence = 1 AND
            meeting_participants.student_id = @student_id AND
            meeting_participants.meeting_id IN (
                SELECT meeting_id
                FROM module_meetings
                    JOIN course_modules ON module_meetings.module_id = course_modules.activity_id
                WHERE course_modules.course_id = @course_id
            )
    )

    DECLARE @result BIT = 0;

    IF @course_meeting_count = @student_meeting_presence_count
        SET @result = 1;

    RETURN @result;
END

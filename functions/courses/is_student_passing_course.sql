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

    DECLARE @course_meeting_presence_count INT = (
        SELECT COUNT(*)
        FROM course_modules
            JOIN module_meetings ON course_modules.activity_id = module_meetings.module_id
        WHERE course_modules.course_id = @course_id AND
              1 = dbo.is_student_present(module_meetings.meeting_id, @student_id)
    )

    DECLARE @result BIT = 0;

    IF @course_meeting_count = @course_meeting_presence_count
        SET @result = 1;

    RETURN @result;
END

CREATE FUNCTION dbo.is_student_present(@meeting_id INT, @student_id INT)
RETURNS BIT
BEGIN
    DECLARE @result BIT = 0;

    IF @student_id IN (SELECT student_id FROM meeting_presence_make_up WHERE meeting_id = @meeting_id)
    BEGIN
        DECLARE @replacement_activity_id INT = dbo.get_make_up_presence_activity(
            @meeting_id,
            @student_id
        );

        IF @replacement_activity_id IN (SELECT activity_id FROM courses)
            SET @result = dbo.is_student_passing_course(
                @replacement_activity_id,
                @student_id
            );
        ELSE IF @replacement_activity_id IN (
            SELECT meeting_id
            FROM meeting_types
            WHERE meeting_type LIKE 'study_%'
        )
            SET @result = dbo.is_student_present(@replacement_activity_id, @student_id);
    END
    ELSE IF @student_id IN (SELECT student_id FROM meeting_presence WHERE meeting_id = @meeting_id)
        SET @result = 1;

    RETURN @result;
END

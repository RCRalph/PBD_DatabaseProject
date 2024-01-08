CREATE FUNCTION is_conditional_presence_cycle(@meeting_id INT, @student_id INT)
RETURNS BIT
BEGIN
    DECLARE @slow_activity_id INT = @meeting_id;
    DECLARE @fast_activity_id INT = dbo.get_make_up_presence_activity(@meeting_id, @student_id);

    WHILE @fast_activity_id IS NOT NULL AND @slow_activity_id <> @fast_activity_id
    BEGIN
        SET @slow_activity_id = dbo.get_make_up_presence_activity(
            @slow_activity_id,
            @student_id
        );

        SET @fast_activity_id = dbo.get_make_up_presence_activity(
            dbo.get_make_up_presence_activity(@fast_activity_id, @student_id),
            @student_id
        );
    END

    DECLARE @result BIT = 1;
    IF @fast_activity_id IS NULL
        SET @result = 0;

    RETURN @result;
END

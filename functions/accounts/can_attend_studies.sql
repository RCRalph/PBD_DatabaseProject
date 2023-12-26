CREATE FUNCTION can_attend_studies(@user_id INT)
RETURNS BIT
BEGIN
    DECLARE @result BIT = 0;

    IF @user_id IN (SELECT user_id FROM students) AND
       @user_id IN (SELECT student_id FROM addresses)
    BEGIN
        SET @result = 1;
    END

    RETURN @result;
END

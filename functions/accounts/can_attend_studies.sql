CREATE FUNCTION can_attend_studies(@user_id INT)
RETURNS BIT
BEGIN
    DECLARE @result BIT = 0;

    IF @user_id IN (SELECT user_id FROM students) AND
       @user_id IN (SELECT student_id FROM addresses)
        SET @result = 1

    RETURN @result;
END

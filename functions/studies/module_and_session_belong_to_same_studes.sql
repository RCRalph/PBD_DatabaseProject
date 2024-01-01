CREATE FUNCTION study_module_and_session_same_studies(@module_id INT, @session_id INT)
RETURNS BIT
BEGIN
    DECLARE @result BIT = 0,
        @module_study_id INT = (SELECT study_id FROM study_modules WHERE activity_id = @module_id),
        @session_study_id INT = (SELECT study_id FROM study_sessions WHERE activity_id = @session_id);

    IF @module_study_id = @session_study_id
        SET @result = 1;

    RETURN @result;
END

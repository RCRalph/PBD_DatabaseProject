CREATE FUNCTION is_study_module_empty(@module_id INT)
RETURNS BIT
BEGIN
    RETURN (
        SELECT IIF(COUNT(*) = 0, 1, 0)
        FROM study_meetings
        WHERE module_id = @module_id
    );
END

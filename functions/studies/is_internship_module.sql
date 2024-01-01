CREATE FUNCTION is_internship_module(@module_id INT)
RETURNS BIT
BEGIN
    RETURN (
        SELECT IIF(COUNT(*) = 0, 1, 0)
        FROM study_meeting_information
        WHERE module_id = @module_id AND meeting_type <> 'internship'
    );
END

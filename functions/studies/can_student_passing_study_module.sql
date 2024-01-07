CREATE FUNCTION can_student_pass_study_module(@module_id INT, @student_id INT)
RETURNS BIT
BEGIN
    DECLARE @study_module_meeting_count INT = (
        SELECT COUNT(*)
        FROM study_meetings
        WHERE module_id = @module_id
    );

    DECLARE @study_module_meeting_presence_count INT = (
        SELECT COUNT(*)
        FROM meeting_participants
        WHERE student_id = @student_id AND
              presence = 1 AND
              meeting_id IN (
                  SELECT meeting_id
                  FROM study_meetings
                  WHERE module_id = @module_id
              )
    );

    DECLARE @result BIT = 0;

    IF @student_id NOT IN (SELECT student_id FROM study_module_passes WHERE module_id = @module_id) AND
       @study_module_meeting_presence_count >= @study_module_meeting_count * 0.8
        SET @result = 1;

    RETURN @result;
END

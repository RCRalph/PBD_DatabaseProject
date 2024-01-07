CREATE FUNCTION is_student_passing_internships(@study_id INT, @student_id INT)
RETURNS BIT
BEGIN
    DECLARE @internship_meeting_count INT = (
        SELECT COUNT(*)
        FROM study_meeting_information
        WHERE study_id = @study_id AND
              meeting_type = 'internship'
    );

    DECLARE @internship_meeting_presence_count INT = (
        SELECT COUNT(*)
        FROM study_meeting_information
            JOIN meeting_participants ON study_meeting_information.meeting_id = meeting_participants.meeting_id
        WHERE meeting_participants.student_id = @student_id AND
              meeting_participants.presence = 1 AND
              study_meeting_information.study_id = @study_id AND
              study_meeting_information.meeting_type = 'internship'
    )

    DECLARE @result BIT = 0;

    IF @internship_meeting_count = @internship_meeting_presence_count
        SET @result = 1;

    RETURN @result;
END

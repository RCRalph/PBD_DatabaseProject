CREATE FUNCTION is_student_passing_studies(@study_id INT, @student_id INT)
    RETURNS BIT
BEGIN
    DECLARE @study_module_count INT = (
        SELECT COUNT(*)
        FROM studies
            JOIN study_modules ON studies.activity_id = study_modules.study_id
        WHERE studies.activity_id = @study_id AND
              dbo.is_internship_module(study_modules.activity_id) = 0
    );

    DECLARE @module_passes_count INT = (
        SELECT COUNT(*)
        FROM study_module_passes
            JOIN study_modules ON study_module_passes.module_id = study_modules.activity_id
        WHERE study_modules.study_id = @study_id AND
              study_module_passes.student_id = @student_id
    )

    DECLARE @result BIT = 0;

    IF 1 = dbo.is_student_passing_internships(@study_id, @student_id) AND
       @study_module_count = @module_passes_count
        SET @result = 1;

    RETURN @result;
END

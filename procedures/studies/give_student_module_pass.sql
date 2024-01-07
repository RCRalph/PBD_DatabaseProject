CREATE PROCEDURE give_student_module_pass
    @module_id INT,
    @student_id INT
AS BEGIN
    IF @student_id NOT IN (SELECT user_id FROM students)
        THROW 50000, 'Student not found', 11;
    ELSE IF @module_id NOT IN (SELECT activity_id FROM study_modules)
        THROW 50001, 'Study module not found', 11;
    ELSE IF @student_id NOT IN (
        SELECT student_id
        FROM product_owners
            JOIN study_modules ON product_owners.product_id = study_modules.study_id
        WHERE study_modules.activity_id = @module_id
    )
        THROW 50002, 'Student does not attend these studies', 16;
    ELSE IF 0 = dbo.can_student_pass_study_module(@module_id, @student_id)
        THROW 50003, 'Cannot give a pass to the student', 16;

    INSERT INTO study_module_passes (student_id, module_id)
    VALUES (@student_id, @module_id)
END

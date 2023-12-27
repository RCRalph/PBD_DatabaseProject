CREATE PROCEDURE delete_student
    @student_id INT
AS BEGIN
    IF @student_id NOT IN (SELECT user_id FROM students)
        THROW 50000, 'Student not found', 11;

    DELETE shopping_cart WHERE student_id = @student_id;
    DELETE addresses WHERE student_id = @student_id;
    DELETE students WHERE user_id = @student_id;
    DELETE users WHERE id = @student_id;
END

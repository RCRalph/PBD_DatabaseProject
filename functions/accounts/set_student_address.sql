CREATE PROCEDURE set_student_address
    @student_id INT,
    @street NVARCHAR(128),
    @zip_code NVARCHAR(8),
    @city_id INT
AS BEGIN
    IF @student_id NOT IN (SELECT id FROM users)
    BEGIN
        THROW 50000, 'User not found', 11;
    END
    ELSE IF @student_id NOT IN (SELECT user_id FROM students)
    BEGIN
        THROW 50001, 'User is not a student', 11;
    END
    ELSE IF @city_id NOT IN (SELECT id FROM cities)
    BEGIN
        THROW 50002, 'City not found', 11;
    END

    INSERT INTO addresses (student_id, street, zip_code, city_id)
    VALUES (@student_id, @street, @zip_code, @city_id);
END

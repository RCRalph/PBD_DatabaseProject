CREATE PROCEDURE set_student_address
    @student_id INT,
    @street NVARCHAR(128),
    @zip_code NVARCHAR(8),
    @city_id INT
AS BEGIN
    IF @student_id NOT IN (SELECT id FROM users)
        THROW 50000, 'User not found', 11;
    ELSE IF @student_id NOT IN (SELECT user_id FROM students)
        THROW 50001, 'User is not a student', 11;
    ELSE IF @city_id NOT IN (SELECT id FROM cities)
        THROW 50002, 'City not found', 11;

    IF @student_id IN (SELECT student_id FROM addresses)
        UPDATE addresses
        SET street = @street, zip_code = @zip_code, city_id = @city_id
        WHERE student_id = @student_id;
    ELSE
        INSERT INTO addresses (student_id, street, zip_code, city_id)
        VALUES (@student_id, @street, @zip_code, @city_id);
END

CREATE FUNCTION create_tutor(
    @email NVARCHAR(64),
    @password NVARCHAR(64),
    @first_name NVARCHAR(64),
    @last_name NVARCHAR(64),
    @phone NVARCHAR(16)
) RETURNS INT
AS BEGIN
    INSERT INTO users (email, password, first_name, last_name, phone)
    VALUES (@email, @password, @first_name, @last_name, @phone);

    DECLARE @user_id INT = (SELECT @@IDENTITY);

    INSERT INTO tutors (user_id)
    VALUES (@user_id);

    RETURN @user_id;
END

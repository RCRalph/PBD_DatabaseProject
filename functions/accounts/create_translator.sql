CREATE PROCEDURE create_translator
    @email NVARCHAR(64),
    @password NVARCHAR(64),
    @first_name NVARCHAR(64),
    @last_name NVARCHAR(64),
    @phone NVARCHAR(16)
AS BEGIN
    INSERT INTO users (email, password, first_name, last_name, phone)
    VALUES (@email, @password, @first_name, @last_name, @phone);

    DECLARE @user_id INT = (SELECT @@IDENTITY);

    INSERT INTO translators (user_id)
    VALUES (@user_id);
END

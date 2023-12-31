CREATE PROCEDURE create_coordinator
    @email NVARCHAR(64),
    @password NVARCHAR(64),
    @first_name NVARCHAR(64),
    @last_name NVARCHAR(64),
    @phone NVARCHAR(16),
    @user_id INT OUTPUT
AS BEGIN
    DECLARE @inserted_user TABLE (id INT);

    INSERT INTO users (email, password, first_name, last_name, phone)
    OUTPUT INSERTED.id INTO @inserted_user
    VALUES (@email, @password, @first_name, @last_name, @phone);

    SELECT @user_id = id FROM @inserted_user;

    INSERT INTO coordinators (user_id)
    VALUES (@user_id);
END

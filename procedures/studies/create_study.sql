CREATE PROCEDURE create_study
    @title NVARCHAR(128),
    @description NVARCHAR(MAX),
    @entry_fee MONEY,
    @place_limit INT,
    @meeting_id INT OUTPUT
AS BEGIN
    IF @entry_fee < 0
        THROW 50000, 'Entry fee cannot be negative', 16;
    ELSE IF @place_limit <= 0
        THROW 50001, 'Place limit has to be positive', 11;

    DECLARE @inserted_activity TABLE (id INT);

    INSERT INTO activities (title, description)
    OUTPUT INSERTED.id INTO @inserted_activity
    VALUES (@title, @description);

    SELECT @meeting_id = id FROM @inserted_activity;

    INSERT INTO studies (activity_id, place_limit)
    VALUES (@meeting_id, @place_limit);

    INSERT INTO products (activity_id, price)
    VALUES (@meeting_id, @entry_fee);
END

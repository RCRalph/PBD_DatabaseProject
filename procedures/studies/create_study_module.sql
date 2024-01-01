CREATE PROCEDURE create_study_module
    @study_id INT,
    @title NVARCHAR(128),
    @description NVARCHAR(MAX),
    @coordinator_id INT,
    @module_id INT OUTPUT
AS BEGIN
    IF @study_id NOT IN (SELECT activity_id FROM studies)
        THROW 50000, 'Study not found', 11;
    ELSE IF @coordinator_id NOT IN (SELECT user_id FROM coordinators)
        THROW 50001, 'Coordinator not found', 11;

    DECLARE @inserted_activity TABLE (id INT);

    INSERT INTO activities (title, description)
    OUTPUT INSERTED.id INTO @inserted_activity
    VALUES (@title, @description);

    SELECT @module_id = id FROM @inserted_activity;

    INSERT INTO study_modules (activity_id, study_id, coordinator_id)
    VALUES (@module_id, @study_id, @coordinator_id);
END

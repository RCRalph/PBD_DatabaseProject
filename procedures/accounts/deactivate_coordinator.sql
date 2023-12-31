CREATE PROCEDURE deactivate_coordinator
    @coordinator_id INT
AS BEGIN
    IF @coordinator_id NOT IN (SELECT user_id FROM coordinators)
        THROW 50000, 'Coordinator not found', 11;

    UPDATE coordinators
    SET active = 0
    WHERE user_id = @coordinator_id;
END

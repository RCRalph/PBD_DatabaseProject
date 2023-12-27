CREATE PROCEDURE deactivate_tutor
    @tutor_id INT
AS BEGIN
    IF @tutor_id NOT IN (SELECT user_id FROM tutors)
        THROW 50000, 'Tutor not found', 11;

    UPDATE tutors
    SET active = 0
    WHERE user_id = @tutor_id;
END

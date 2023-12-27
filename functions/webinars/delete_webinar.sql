CREATE PROCEDURE delete_webinar
    @webinar_id INT
AS BEGIN
    IF @webinar_id NOT IN (SELECT webinar_id FROM webinars)
        THROW 50000, 'Webinar not found', 11;

    UPDATE products
    SET active = 0
    WHERE activity_id = @webinar_id;

    DELETE meetings WHERE activity_id = @webinar_id;
    DELETE meeting_schedule WHERE meeting_id = @webinar_id;
    DELETE online_synchronous_meetings WHERE meeting_id = @webinar_id;
    DELETE meeting_translators WHERE meeting_id = @webinar_id;
END

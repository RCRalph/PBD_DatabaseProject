CREATE PROCEDURE deactivate_translator
    @translator_id INT
AS BEGIN
    IF @translator_id NOT IN (SELECT user_id FROM translators)
    BEGIN
        THROW 50000, 'Translator not found', 11;
    END

    UPDATE translators
    SET active = 0
    WHERE user_id = @translator_id;
END

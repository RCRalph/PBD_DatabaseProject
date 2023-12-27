CREATE PROCEDURE assign_language_to_webinar
    @webinar_id INT,
    @language_id INT,
    @translator_id INT
AS BEGIN
    IF @webinar_id NOT IN (SELECT webinar_id FROM webinar_information)
        THROW 50000, 'Webinar not found', 11;
    ELSE IF @language_id IN (SELECT recording_url FROM webinar_information)
        THROW 50001, 'Language not found', 11;
    ELSE IF @translator_id IS NULL
        THROW 50002, 'Translator not found', 11;
    ELSE IF NOT EXISTS (
        SELECT 1
        FROM translators_languages
        WHERE translator_id = @translator_id AND @language_id = @language_id
    )
        THROW 50003, 'Translator cannot translate this language', 11;

    IF @webinar_id IN (SELECT meeting_id FROM meeting_translators)
        UPDATE meeting_translators
        SET language_id = @language_id, translator_id = @translator_id
        WHERE meeting_id = @webinar_id
    ELSE
        INSERT INTO meeting_translators (meeting_id, translator_id, language_id)
        VALUES (@webinar_id, @translator_id, @language_id)
END

CREATE PROCEDURE remove_language_from_translator
    @translator_id INT,
    @language_id INT
AS BEGIN
    IF @translator_id NOT IN (SELECT user_id FROM translators)
    BEGIN
        THROW 50000, 'Translator not found', 11;
    END
    ELSE IF @language_id NOT IN (SELECT id FROM languages)
    BEGIN
        THROW 50001, 'Language not found', 11;
    END
    ELSE IF NOT EXISTS (
        SELECT translator_id, language_id
        FROM translators_languages
        WHERE translator_id = @translator_id AND
            language_id = @language_id
    )
    BEGIN
        THROW 50002, 'Language was not assigned to translator', 16;
    END

    DELETE translators_languages WHERE
        translator_id = @translator_id AND
        language_id = @language_id;
END

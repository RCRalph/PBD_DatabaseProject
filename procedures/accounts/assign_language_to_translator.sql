CREATE PROCEDURE assign_language_to_translator
    @translator_id INT,
    @language_id INT
AS BEGIN
    IF @translator_id NOT IN (SELECT user_id FROM translators)
        THROW 50000, 'Translator not found', 11;
    ELSE IF @language_id NOT IN (SELECT id FROM languages)
        THROW 50001, 'Language not found', 11;
    ELSE IF EXISTS (
        SELECT translator_id, language_id
        FROM translators_languages
        WHERE translator_id = @translator_id AND
              language_id = @language_id
    )
        THROW 50002, 'Language already assigned to translator', 16;

    INSERT INTO translators_languages (translator_id, language_id)
    VALUES (@translator_id, @language_id);
END

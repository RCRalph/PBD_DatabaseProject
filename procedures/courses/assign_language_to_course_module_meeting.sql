CREATE PROCEDURE assign_language_to_course_module_meeting
    @meeting_id INT,
    @language_id INT,
    @translator_id INT
AS BEGIN
    IF @meeting_id NOT IN (SELECT meeting_id FROM course_meeting_information)
        THROW 50000, 'Meeting not found', 11;
    ELSE IF @language_id NOT IN (SELECT id FROM languages)
        THROW 50001, 'Language not found', 11;
    ELSE IF @translator_id NOT IN (SELECT user_id FROM translators)
        THROW 50002, 'Translator not found', 11;
    ELSE IF NOT EXISTS (
        SELECT 1
        FROM translators_languages
        WHERE translator_id = @translator_id AND language_id = @language_id
    )
        THROW 50003, 'Translator cannot translate this language', 11;

    IF @meeting_id IN (SELECT meeting_id FROM meeting_translators)
        UPDATE meeting_translators
        SET language_id = @language_id, translator_id = @translator_id
        WHERE meeting_id = @meeting_id
    ELSE
        INSERT INTO meeting_translators (meeting_id, translator_id, language_id)
        VALUES (@meeting_id, @translator_id, @language_id)
END

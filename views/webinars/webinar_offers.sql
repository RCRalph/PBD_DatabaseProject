CREATE VIEW webinar_offers AS
SELECT
    webinar_information.webinar_id,
    webinar_information.title,
    webinar_information.description,
    L.first_name + ' ' + L.last_name AS lecturer,
    FORMAT(webinar_information.start_time, 'yyyy-MM-dd HH:mm') AS start_time,
    FORMAT(webinar_information.end_time, 'yyyy-MM-dd HH:mm') AS end_time,
    ISNULL(languages.name, 'Polski') AS language,
    T.first_name + ' ' + T.last_name AS translator,
    webinar_information.online_platform,
    webinar_information.price
FROM webinar_information
    JOIN tutors ON webinar_information.tutor_id = tutors.user_id
    JOIN users L ON tutors.user_id = L.id
    LEFT JOIN translators ON webinar_information.translator_id = translators.user_id
    LEFT JOIN users T ON translators.user_id = T.id
    LEFT JOIN languages ON webinar_information.language_id = languages.id

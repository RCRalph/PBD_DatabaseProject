CREATE VIEW webinar_offers AS
SELECT
    webinars.webinar_id,
    webinars.title,
    webinars.description,
    L.first_name + ' ' + L.last_name AS lecturer,
    FORMAT(webinars.start_time, 'yyyy-MM-dd hh:mm') AS start_time,
    FORMAT(webinars.end_time, 'yyyy-MM-dd hh:mm') AS end_time,
    webinars.language,
    T.first_name + ' ' + T.last_name AS translator,
    webinars.online_platform,
    webinars.price
FROM webinars
    JOIN tutors ON webinars.tutor_id = tutors.user_id
    JOIN users L ON tutors.user_id = L.id
    LEFT JOIN translators ON webinars.translator_id = translators.user_id
    LEFT JOIN users T ON translators.user_id = T.id

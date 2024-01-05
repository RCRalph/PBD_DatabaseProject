CREATE VIEW product_information AS
SELECT
    products.activity_id AS product_id,
    activities.title AS title,
    activities.description AS description,
    CASE
        WHEN activities.id IN (SELECT study_id FROM study_information) AND
             activities.id NOT IN (SELECT course_id FROM course_information) AND
             activities.id NOT IN (SELECT webinar_id FROM webinar_information) AND
             activities.id NOT IN (SELECT activity_id FROM study_sessions) AND
             activities.id NOT IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'on_site') AND
             activities.id NOT IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'online_asynchronous') AND
             activities.id NOT IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'online_synchronous')
        THEN 'study'

        WHEN activities.id NOT IN (SELECT study_id FROM study_information) AND
             activities.id IN (SELECT course_id FROM course_information) AND
             activities.id NOT IN (SELECT webinar_id FROM webinar_information) AND
             activities.id NOT IN (SELECT activity_id FROM study_sessions) AND
             activities.id NOT IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'on_site') AND
             activities.id NOT IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'online_asynchronous') AND
             activities.id NOT IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'online_synchronous')
        THEN 'course'

        WHEN activities.id NOT IN (SELECT study_id FROM study_information) AND
             activities.id NOT IN (SELECT course_id FROM course_information) AND
             activities.id IN (SELECT webinar_id FROM webinar_information) AND
             activities.id NOT IN (SELECT activity_id FROM study_sessions) AND
             activities.id NOT IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'on_site') AND
             activities.id NOT IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'online_asynchronous') AND
             activities.id NOT IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'online_synchronous')
        THEN 'webinar'

        WHEN activities.id NOT IN (SELECT study_id FROM study_information) AND
             activities.id NOT IN (SELECT course_id FROM course_information) AND
             activities.id NOT IN (SELECT webinar_id FROM webinar_information) AND
             activities.id IN (SELECT activity_id FROM study_sessions) AND
             activities.id NOT IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'on_site') AND
             activities.id NOT IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'online_asynchronous') AND
             activities.id NOT IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'online_synchronous')
        THEN 'study_session'

        WHEN activities.id NOT IN (SELECT study_id FROM study_information) AND
             activities.id NOT IN (SELECT course_id FROM course_information) AND
             activities.id NOT IN (SELECT webinar_id FROM webinar_information) AND
             activities.id NOT IN (SELECT activity_id FROM study_sessions) AND
             activities.id IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'on_site') AND
             activities.id NOT IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'online_asynchronous') AND
             activities.id NOT IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'online_synchronous')
        THEN 'study_on_site_meeting'

        WHEN activities.id NOT IN (SELECT study_id FROM study_information) AND
             activities.id NOT IN (SELECT course_id FROM course_information) AND
             activities.id NOT IN (SELECT webinar_id FROM webinar_information) AND
             activities.id NOT IN (SELECT activity_id FROM study_sessions) AND
             activities.id NOT IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'on_site') AND
             activities.id IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'online_asynchronous') AND
             activities.id NOT IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'online_synchronous')
        THEN 'study_online_asynchronous_meeting'

        WHEN activities.id NOT IN (SELECT study_id FROM study_information) AND
             activities.id NOT IN (SELECT course_id FROM course_information) AND
             activities.id NOT IN (SELECT webinar_id FROM webinar_information) AND
             activities.id NOT IN (SELECT activity_id FROM study_sessions) AND
             activities.id NOT IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'on_site') AND
             activities.id NOT IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'online_asynchronous') AND
             activities.id IN (SELECT meeting_id FROM study_meeting_information WHERE meeting_type = 'online_synchronous')
        THEN 'study_online_synchronous_meeting'
    END AS product_type,
    products.price AS price
FROM products
    JOIN activities ON products.activity_id = activities.id
WHERE products.active = 1

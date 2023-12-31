CREATE VIEW course_offers AS
SELECT
    course_information.course_id,
    course_information.title,
    course_information.description,
    C.first_name + ' ' + C.last_name AS coordinator,
    course_information.start_day,
    course_information.end_day,
    course_information.language,
    course_information.price
FROM course_information
    JOIN coordinators ON course_information.coordinator_id = coordinators.user_id
    JOIN users C ON coordinators.user_id = C.id

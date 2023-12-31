CREATE VIEW course_information AS
SELECT
    courses.activity_id AS course_id,
    activities.title AS title,
    activities.description AS description,
    courses.coordinator_id AS coordinator_id,
    course_schedule.start_day AS start_day,
    course_schedule.end_day AS end_day,
    dbo.get_course_language(courses.activity_id) AS language,
    (
        SELECT MIN(course_module_information.place_limit)
        FROM course_module_information
            JOIN course_modules ON course_module_information.module_id = course_modules.activity_id
        WHERE course_modules.course_id = courses.activity_id AND
            course_module_information.place_limit IS NOT NULL
    ) AS place_limit,
    (
        SELECT COUNT(*)
        FROM course_module_information
            JOIN course_modules ON course_module_information.module_id = course_modules.activity_id
        WHERE course_modules.course_id = courses.activity_id AND
            course_module_information.module_type = 'on_site'
    ) AS on_site_module_count,
    (
        SELECT COUNT(*)
        FROM course_module_information
            JOIN course_modules ON course_module_information.module_id = course_modules.activity_id
        WHERE course_modules.course_id = courses.activity_id AND
            course_module_information.module_type = 'online_synchronous'
    ) AS online_synchronous_module_count,
    (
        SELECT COUNT(*)
        FROM course_module_information
            JOIN course_modules ON course_module_information.module_id = course_modules.activity_id
        WHERE course_modules.course_id = courses.activity_id AND
            course_module_information.module_type = 'online_asynchronous'
    ) AS online_asynchronous_module_count,
    (
        SELECT COUNT(*)
        FROM course_module_information
            JOIN course_modules ON course_module_information.module_id = course_modules.activity_id
        WHERE course_modules.course_id = courses.activity_id AND
            course_module_information.module_type = 'hybrid'
    ) AS hybrid_module_count,
    products.price
FROM courses
    JOIN products ON courses.activity_id = products.activity_id
    JOIN activities ON courses.activity_id = activities.id
    JOIN course_schedule ON courses.activity_id = course_schedule.course_id

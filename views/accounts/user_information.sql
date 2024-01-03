CREATE VIEW user_information AS
SELECT
    users.id AS id,
    users.email AS email,
    users.first_name AS first_name,
    users.last_name AS last_name,
    users.phone AS phone,
    CASE
        WHEN users.id IN (SELECT user_id FROM students) AND
             users.id NOT IN (SELECT user_id FROM coordinators) AND
             users.id NOT IN (SELECT user_id FROM translators) AND
             users.id NOT IN (SELECT user_id FROM tutors)
        THEN 'student'

        WHEN users.id NOT IN (SELECT user_id FROM students) AND
             users.id IN (SELECT user_id FROM coordinators) AND
             users.id NOT IN (SELECT user_id FROM translators) AND
             users.id NOT IN (SELECT user_id FROM tutors)
        THEN 'coordinator'

        WHEN users.id NOT IN (SELECT user_id FROM students) AND
             users.id NOT IN (SELECT user_id FROM coordinators) AND
             users.id IN (SELECT user_id FROM translators) AND
             users.id NOT IN (SELECT user_id FROM tutors)
        THEN 'translator'

        WHEN users.id NOT IN (SELECT user_id FROM students) AND
             users.id NOT IN (SELECT user_id FROM coordinators) AND
             users.id NOT IN (SELECT user_id FROM translators) AND
             users.id IN (SELECT user_id FROM tutors)
        THEN 'tutor'
    END AS user_role
FROM users

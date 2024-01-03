CREATE VIEW student_address AS
SELECT
    students.user_id AS student_id,
    users.first_name + ' ' + users.last_name AS name,
    addresses.street AS street,
    addresses.zip_code AS zip_code,
    cities.name AS city,
    countries.name AS country
FROM students
    JOIN addresses ON students.user_id = addresses.student_id
    JOIN cities ON addresses.city_id = cities.id
    JOIN countries ON cities.country_id = countries.id
    JOIN users ON students.user_id = users.id

CREATE VIEW product_place_limits AS
WITH place_limits AS (
    SELECT
        order_details.product_id,
        COUNT(orders.student_id) AS product_owner_count,
        CASE
            WHEN product_information.product_type = 'study'
            THEN (SELECT place_limit FROM study_information WHERE study_id = order_details.product_id)

            WHEN product_information.product_type = 'course'
            THEN (SELECT place_limit FROM course_information WHERE course_id = order_details.product_id)

            WHEN product_information.product_type = 'study_on_site_meeting'
            THEN (SELECT free_listener_place_limit FROM study_meeting_information WHERE meeting_id = order_details.product_id)
        END AS place_limit
    FROM order_details
        JOIN order_statuses ON order_details.status_id = order_statuses.id
        JOIN orders ON order_details.order_id = orders.id
        RIGHT JOIN product_information ON order_details.product_id = product_information.product_id
    WHERE order_statuses.name <> N'Zamówienie anulowane'
    GROUP BY order_details.product_id, product_information.product_type
)

SELECT *, place_limit - product_owner_count AS places_available
FROM place_limits

SELECT
    orders.id AS order_id,
    orders.student_id AS student_id,
    order_details.product_id AS product_id,
    product_information.product_type AS product_type,
    order_details.price AS price,
    order_statuses.name AS order_status,
    ROUND(dbo.advance_payment_value(orders.order_date) * order_details.price, 2) AS advance_payment_value
FROM order_details
    JOIN orders ON order_details.order_id = orders.id
    JOIN order_statuses ON order_details.status_id = order_statuses.id
    JOIN product_information ON order_details.product_id = product_information.product_id

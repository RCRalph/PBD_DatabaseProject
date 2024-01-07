CREATE VIEW unpaid_special_permissions AS
SELECT
    ordered_products.student_id AS student_id,
    SUM(ordered_products.payment_left) AS payment_left
FROM ordered_products
WHERE ordered_products.order_status LIKE N'Płatność odroczona%'
GROUP BY ordered_products.student_id

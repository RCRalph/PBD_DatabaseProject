CREATE VIEW product_owners AS
SELECT order_details.product_id, orders.student_id
FROM orders
    JOIN order_details ON orders.id = order_details.order_id
    JOIN order_statuses ON order_details.status_id = order_statuses.id
WHERE order_statuses.name IN (
    N'Zamówienie opłacone',
    N'Płatność odroczona',
    N'Płatność odroczona, wpłacona zaliczka'
)

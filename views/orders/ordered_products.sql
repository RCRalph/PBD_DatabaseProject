CREATE VIEW ordered_products AS
SELECT
    orders.student_id AS student_id,
    order_details.product_id AS product_id,
    order_statuses.name AS order_status,
    ROUND(order_details.price * (1 - IIF(
        order_statuses.name LIKE N'%zaliczka',
        dbo.advance_payment_value(orders.order_date),
        IIF(order_statuses.name = N'Zamówienie opłacone', 1, 0)
    )), 2) AS payment_left
FROM order_details
    JOIN orders ON order_details.order_id = orders.id
    JOIN order_statuses ON order_details.status_id = order_statuses.id
WHERE order_statuses.name <> N'Zamówienie anulowane'

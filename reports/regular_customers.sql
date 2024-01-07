CREATE VIEW regular_customers AS
SELECT
    student_id,
    COUNT(order_date) AS order_count
FROM orders
WHERE order_date >= DATEADD(year, -2, GETDATE())
GROUP BY student_id
HAVING COUNT(order_date) >= 10

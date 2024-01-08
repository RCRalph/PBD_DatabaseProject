CREATE VIEW orders_only_paid_advancement AS
SELECT
    ordered_products.student_id,
    product_payment_information.product_id,
    product_payment_information.latest_payment_time
FROM product_payment_information
    JOIN ordered_products ON product_payment_information.product_id = ordered_products.product_id
WHERE ordered_products.order_status IN (N'Nowe zamówienie', N'Wpłacona zaliczka') AND
      product_payment_information.latest_payment_time < GETDATE()

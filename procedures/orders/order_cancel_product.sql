CREATE PROCEDURE order_cancel_product
    @order_id NVARCHAR(128),
    @product_id INT
AS BEGIN
    IF @order_id NOT IN (SELECT id FROM orders)
        THROW 50000, 'Order not found', 11;
    ELSE IF @product_id NOT IN (SELECT activity_id FROM products)
        THROW 50001, 'Product not found', 11;
    ELSE IF @product_id NOT IN (SELECT product_id FROM order_details WHERE order_id = @order_id)
        THROW 50002, 'Product was not ordered in this order', 11;

    DECLARE @current_order_status_id INT = (
        SELECT status_id
        FROM order_details
        WHERE order_id = @order_id AND product_id = @product_id
    )

    IF @current_order_status_id IN (SELECT id FROM order_statuses WHERE name IN (N'Zamówienie opłacone'))
        THROW 50003, 'Cannot cancel a completed order', 16;
    ELSE IF @current_order_status_id IN (SELECT id from order_statuses WHERE name LIKE N'Płatność odroczona%')
        THROW 50004, 'Cannot cancel an order with special permission applied', 16;

    UPDATE order_details
    SET status_id = (SELECT id FROM order_statuses WHERE name = N'Zamówienie anulowane')
    WHERE order_id = @order_id AND @product_id = @product_id;
END

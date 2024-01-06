CREATE PROCEDURE order_accept_advancement_payment
    @order_id NVARCHAR(128),
    @product_id INT,
    @payment_status BIT
AS BEGIN
    IF @payment_status = 0
        THROW 50000, 'Payment not successful', 16;
    ELSE IF @order_id NOT IN (SELECT id FROM orders)
        THROW 50001, 'Order not found', 11;
    ELSE IF @product_id NOT IN (SELECT activity_id FROM products)
        THROW 50002, 'Product not found', 11;
    ELSE IF @product_id NOT IN (SELECT product_id FROM order_details WHERE order_id = @order_id)
        THROW 50003, 'Product was not ordered in this order', 11;
    ELSE IF @product_id NOT IN (SELECT product_id FROM product_payment_information WHERE accepts_advance_payments = 1)
        THROW 50004, 'Product does not accept advance payments', 16;

    DECLARE @current_order_status_id INT = (
        SELECT status_id
        FROM order_details
        WHERE order_id = @order_id AND product_id = @product_id
    );

    IF @current_order_status_id IN (SELECT id FROM order_statuses WHERE name LIKE N'%zaliczka')
        THROW 50005, 'Advancement already paid', 16;
    ELSE IF @current_order_status_id = (SELECT id FROM order_statuses WHERE name = N'Zamówienie opłacone')
        THROW 50006, 'Full payment already accepted', 16;
    ELSE IF @current_order_status_id = (SELECT id FROM order_statuses WHERE name = N'Zamówienie anulowane')
        THROW 50007, 'Product order was canceled', 16;
    ELSE IF GETDATE() > (SELECT latest_payment_time FROM product_payment_information WHERE product_id = @product_id) AND
       @current_order_status_id IN (SELECT id FROM order_statuses WHERE name NOT LIKE N'Płatność odroczona%')
        THROW 50008, 'Missed payment deadline', 16;
    ELSE IF 0 >= (SELECT places_left FROM product_places_left WHERE product_id = @product_id)
        THROW 50009, 'Place limit reached', 16;

    UPDATE order_details
    SET status_id = (
        SELECT id
        FROM order_statuses
        WHERE name = IIF(
            @current_order_status_id = (SELECT id FROM order_statuses WHERE name = N'Płatność odroczona'),
            N'Płatność odroczona, wpłacona zaliczka',
            N'Wpłacona zaliczka'
        )
    )
    WHERE order_id = @order_id AND product_id = @product_id;
END

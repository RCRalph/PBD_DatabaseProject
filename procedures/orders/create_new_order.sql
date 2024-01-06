CREATE PROCEDURE create_new_order
    @student_id INT,
    @payment_url NVARCHAR(128),
    @order_id INT OUTPUT
AS BEGIN
    IF @student_id NOT IN (SELECT user_id FROM students)
        THROW 50000, 'Student not found', 11;
    ELSE IF 0 = (SELECT COUNT(*) FROM shopping_cart WHERE student_id = @student_id)
        THROW 50001, 'Shopping cart is empty', 16;
    ELSE IF @payment_url IN (SELECT payment_url FROM orders)
        THROW 50002, 'Payment URL must be unique', 16;

    DECLARE @product_id INT, @price MONEY;
    DECLARE student_shopping_cart_cursor CURSOR FOR
        SELECT
            products.activity_id,
            products.price
        FROM shopping_cart
            JOIN products ON shopping_cart.product_id = products.activity_id
        WHERE student_id = @student_id;

    OPEN student_shopping_cart_cursor;
    FETCH NEXT FROM student_shopping_cart_cursor INTO @product_id, @price;

    WHILE @@FETCH_STATUS = 0
    BEGIN
        IF 0 = dbo.can_order_product_in_shopping_cart(@student_id, @product_id)
            THROW 50003, 'Product cannot be ordered', 16;

        FETCH NEXT FROM student_shopping_cart_cursor INTO @product_id, @price;
    END

    CLOSE student_shopping_cart_cursor;
    DEALLOCATE student_shopping_cart_cursor;

    DECLARE @inserted_order TABLE (id INT);

    INSERT INTO orders (student_id, payment_url)
    OUTPUT INSERTED.id INTO @inserted_order
    VALUES (@student_id, @payment_url)

    SELECT @order_id = id FROM @inserted_order;

    INSERT INTO order_details (order_id, product_id, price, status_id)
    SELECT
        @order_id,
        product_id,
        price,
        IIF(
            price = 0,
            (SELECT id FROM order_statuses WHERE name = N'Zamówienie opłacone'),
            (SELECT id FROM order_statuses WHERE name = N'Nowe zamówienie')
        )
    FROM shopping_cart
        JOIN products ON shopping_cart.product_id = products.activity_id
    WHERE student_id = @student_id;

    DELETE shopping_cart
    WHERE student_id = @student_id;
END

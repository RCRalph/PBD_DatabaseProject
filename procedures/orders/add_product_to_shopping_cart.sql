CREATE PROCEDURE add_product_to_shopping_cart
    @student_id INT,
    @product_id INT
AS BEGIN
    IF @student_id NOT IN (SELECT user_id FROM students)
        THROW 50000, 'Student not found', 11;
    ELSE IF @product_id NOT IN (SELECT product_id FROM product_information)
        THROW 50001, 'Product not found', 11;
    ELSE IF @product_id IN (SELECT product_id FROM ordered_products WHERE student_id = @student_id)
        THROW 50002, 'Product is already ordered', 16;
    ELSE IF dbo.can_add_product_to_shopping_cart (@student_id, @product_id) = 0
        THROW 50003, 'Product cannot be added to shopping cart', 16;
    ELSE IF @product_id IN (SELECT product_id FROM shopping_cart WHERE student_id = @student_id)
        THROW 50004, 'Product already in the shopping cart', 16;

    INSERT INTO shopping_cart (product_id, student_id)
    VALUES (@product_id, @student_id);
END

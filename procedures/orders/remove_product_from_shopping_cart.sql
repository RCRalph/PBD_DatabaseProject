CREATE PROCEDURE remove_product_from_shopping_cart
    @student_id INT,
    @product_id INT
AS BEGIN
    IF @student_id NOT IN (SELECT user_id FROM students)
        THROW 50000, 'Student not found', 11;
    ELSE IF @product_id NOT IN (SELECT activity_id FROM products)
        THROW 50001, 'Product not found', 11;
    ELSE IF @product_id NOT IN (SELECT product_id FROM shopping_cart WHERE student_id = @student_id)
        THROW 50002, 'Product not in shopping cart', 11

    DELETE shopping_cart
    WHERE student_id = @student_id AND
          product_id = @product_id
END

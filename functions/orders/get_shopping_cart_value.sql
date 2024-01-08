CREATE FUNCTION get_shopping_cart_value(@student_id INT)
RETURNS MONEY
BEGIN
    DECLARE @result MONEY;

    SELECT @result = ISNULL(SUM(products.price), 0)
    FROM shopping_cart
        JOIN products ON shopping_cart.product_id = products.activity_id
    WHERE shopping_cart.student_id = @student_id

    RETURN @result;
END

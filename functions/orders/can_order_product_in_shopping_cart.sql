CREATE FUNCTION can_order_product_in_shopping_cart(@student_id INT, @product_id INT)
RETURNS BIT
BEGIN
    DECLARE @result BIT = dbo.can_add_product_to_shopping_cart(@student_id, @product_id);

    IF 0 >= (SELECT places_available FROM product_place_limits WHERE product_id = @product_id)
        SET @result = 0;

    RETURN @result;
END

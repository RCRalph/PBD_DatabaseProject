CREATE FUNCTION can_add_product_to_shopping_cart(@user_id INT, @product_id INT)
RETURNS BIT
BEGIN
    DECLARE @result BIT = 0;

    IF @user_id IN (SELECT user_id FROM students) AND
       @product_id IN (SELECT product_id FROM product_information) AND
       @product_id NOT IN (SELECT product_id FROM ordered_products WHERE student_id = @user_id)
        SET @result = 1;

        IF @product_id IN (SELECT product_id FROM product_information WHERE product_type = 'study')
            SET @result = dbo.can_attend_studies(@user_id)
        ELSE IF @product_ID IN (SELECT product_id FROM product_information WHERE product_type = 'study_session') AND
                @product_id NOT IN (
                    SELECT activity_id
                    FROM study_sessions
                    WHERE study_id IN (
                        SELECT product_id
                        FROM product_owners
                        WHERE student_id = @user_id
                    )
                )
            SET @result = 0;

    RETURN @result;
END

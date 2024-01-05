CREATE FUNCTION advance_payment_value(@date date)
RETURNS DECIMAL(3, 3)
BEGIN
    DECLARE @result DECIMAL(3, 3);

    SELECT @result = value
    FROM advance_payments
    WHERE @date BETWEEN advance_payments.start_date AND COALESCE(advance_payments.end_date, @date);

    RETURN @result;
END

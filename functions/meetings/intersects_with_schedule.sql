CREATE FUNCTION intersects_with_schedule(
    @start_time DATETIME,
    @end_time DATETIME,
    @schedule schedule READONLY
) RETURNS BIT
BEGIN
    DECLARE @result BIT = 0;

    IF EXISTS (
        SELECT 1
        FROM @schedule S
        WHERE (
            @start_time BETWEEN S.start_time AND S.end_time OR
            @end_time BETWEEN S.start_time AND S.end_time OR
            S.start_time BETWEEN @start_time AND @end_time
        )
    )
        SET @result = 1;

    RETURN @result;
END

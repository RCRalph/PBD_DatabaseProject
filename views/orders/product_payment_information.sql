CREATE VIEW product_payment_information AS
SELECT
    product_information.product_id,
    product_information.product_type,
    CASE
        WHEN product_information.product_type = 'study'
        THEN (
            SELECT DATEADD(day, -3, start_day)
            FROM study_information
            WHERE study_id = product_information.product_id
        )

        WHEN product_information.product_type = 'study_session'
        THEN (
            SELECT DATEADD(day, -3, start_time)
            FROM study_session_schedule
            WHERE session_id = product_information.product_id
        )

        WHEN product_information.product_type = 'course'
        THEN (
            SELECT DATEADD(day, -3, start_day)
            FROM course_schedule
            WHERE course_id = product_information.product_id
        )

        ELSE (SELECT start_time FROM meeting_schedule WHERE meeting_id = product_information.product_id)
    END AS latest_payment_time,
    IIF(product_information.product_type IN ('study', 'study_session', 'course'), 1, 0) AS accepts_advance_payments
FROM product_information

CREATE VIEW financial_report AS
SELECT
    product_information.product_id,
    product_information.product_type,
    ISNULL(CASE
        WHEN product_information.product_type = 'webinar' OR
             product_information.product_type = 'course'
        THEN SUM(ordered_products.price - ordered_products.payment_left)

        WHEN product_information.product_type = 'study'
        THEN SUM(ordered_products.price - ordered_products.payment_left) + (
            SELECT SUM(OP.price - OP.payment_left)
            FROM product_information AS P_I
                JOIN ordered_products OP ON P_I.product_id = OP.product_id
                JOIN study_sessions SS ON OP.product_id = SS.activity_id
            WHERE P_I.product_id = OP.product_id AND
                  SS.study_id = product_information.product_id
        ) + (
            SELECT SUM(OP.price - OP.payment_left)
            FROM product_information AS P_I
                JOIN ordered_products OP ON P_I.product_id = OP.product_id
                JOIN study_meeting_information SMI ON OP.product_id = SMI.meeting_id
            WHERE P_I.product_id = OP.product_id AND
                SMI.study_id = product_information.product_id
        )
    END, 0) AS revenue
FROM product_information
    LEFT JOIN ordered_products ON product_information.product_id = ordered_products.product_id
WHERE product_information.product_type IN ('webinar', 'course', 'study')
GROUP BY product_information.product_id, product_information.product_type

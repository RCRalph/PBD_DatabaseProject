CREATE VIEW product_places_left AS
SELECT
    product_information.product_id,
    product_place_limits.place_limit - (
        SELECT COUNT(*)
        FROM ordered_products
        WHERE ordered_products.product_id = product_information.product_id AND
              ordered_products.order_status NOT IN (N'Nowe zamówienie', N'Zamówienie anulowane')
    ) AS places_left
FROM product_information
    JOIN product_place_limits ON product_information.product_id = product_place_limits.product_id

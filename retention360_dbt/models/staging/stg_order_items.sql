SELECT
    order_id,
    TRY_TO_NUMBER(order_item_id) AS order_item_id,
    product_id,
    seller_id,

    TRY_TO_TIMESTAMP(shipping_limit_date) AS shipping_limit_datetime,

    TRY_TO_DECIMAL(price, 10, 2) AS price,
    TRY_TO_DECIMAL(freight_value, 10, 2) AS freight_value

FROM {{ source('raw', 'raw_order_items') }}
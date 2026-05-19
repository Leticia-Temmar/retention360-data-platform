WITH orders AS (

    SELECT *
    FROM {{ ref('stg_orders') }}

),

customers AS (

    SELECT *
    FROM {{ ref('stg_customers') }}

),

order_items AS (

    SELECT *
    FROM {{ ref('stg_order_items') }}

),

payments AS (

    SELECT
        order_id,
        SUM(payment_value) AS total_payment_value,
        COUNT(*) AS payment_count,
        MAX(payment_type) AS main_payment_type
    FROM {{ ref('stg_order_payments') }}
    GROUP BY order_id

),

products AS (

    SELECT *
    FROM {{ ref('stg_products') }}

),

sellers AS (

    SELECT *
    FROM {{ ref('stg_sellers') }}

),

category_translation AS (

    SELECT *
    FROM {{ ref('stg_product_category_translation') }}

)

SELECT
    o.order_id,
    o.customer_id,
    c.customer_unique_id,

    o.order_status,
    o.purchase_datetime,
    o.approved_datetime,
    o.carrier_delivery_datetime,
    o.customer_delivery_datetime,
    o.estimated_delivery_datetime,

    oi.order_item_id,
    oi.product_id,
    oi.seller_id,

    p.product_category_name,
    ct.product_category_name_english,

    oi.price,
    oi.freight_value,

    pay.total_payment_value,
    pay.payment_count,
    pay.main_payment_type,

    s.seller_city,
    s.seller_state,

    c.customer_city,
    c.customer_state

FROM orders o

LEFT JOIN customers c
    ON o.customer_id = c.customer_id

LEFT JOIN order_items oi
    ON o.order_id = oi.order_id

LEFT JOIN products p
    ON oi.product_id = p.product_id

LEFT JOIN category_translation ct
    ON p.product_category_name = ct.product_category_name

LEFT JOIN sellers s
    ON oi.seller_id = s.seller_id

LEFT JOIN payments pay
    ON o.order_id = pay.order_id
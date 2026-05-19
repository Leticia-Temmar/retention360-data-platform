WITH product_sales AS (

    SELECT
        oi.product_id,
        oi.order_id,
        oi.seller_id,
        oi.price,
        oi.freight_value,

        p.product_category_name,
        ct.product_category_name_english

    FROM {{ ref('stg_order_items') }} oi

    LEFT JOIN {{ ref('stg_products') }} p
        ON oi.product_id = p.product_id

    LEFT JOIN {{ ref('stg_product_category_translation') }} ct
        ON p.product_category_name = ct.product_category_name

),

product_metrics AS (

    SELECT
        product_id,

        MIN(product_category_name) AS product_category_name,
        MIN(product_category_name_english) AS product_category_name_english,

        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(*) AS total_items_sold,
        COUNT(DISTINCT seller_id) AS total_sellers,

        SUM(price) AS total_revenue,
        AVG(price) AS average_sale_price,

        SUM(freight_value) AS total_freight_value,
        AVG(freight_value) AS average_freight_value

    FROM product_sales
    GROUP BY product_id

)

SELECT *
FROM product_metrics
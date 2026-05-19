SELECT
    product_id,

    product_category_name,
    product_category_name_english,

    total_orders,
    total_items_sold,
    total_sellers,

    total_revenue,
    average_sale_price,

    total_freight_value,
    average_freight_value

FROM {{ ref('curated_products') }}
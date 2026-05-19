SELECT
    DATE_TRUNC('month', purchase_datetime) AS revenue_month,

    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT customer_unique_id) AS active_customers,

    SUM(total_payment_value) AS total_revenue,
    AVG(total_payment_value) AS average_order_value,

    SUM(price) AS product_revenue,
    SUM(freight_value) AS total_freight_value

FROM {{ ref('curated_orders') }}

WHERE order_status = 'delivered'

GROUP BY 1
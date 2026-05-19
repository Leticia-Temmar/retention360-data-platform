SELECT
    customer_unique_id,

    customer_city,
    customer_state,

    first_order_datetime,
    last_order_datetime,

    total_orders,
    total_spent,
    average_order_value,

    delivered_orders,
    failed_orders,

    DATEDIFF(
        'day',
        last_order_datetime,
        CURRENT_DATE
    ) AS days_since_last_order,

    CASE

        WHEN total_spent >= 5000
            THEN 'VIP'

        WHEN DATEDIFF(
            'day',
            last_order_datetime,
            CURRENT_DATE
        ) > 180
            THEN 'At Risk'

        ELSE 'Active'

    END AS customer_segment

FROM {{ ref('curated_customers') }}
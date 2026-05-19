WITH customer_orders AS (

    SELECT
        c.customer_unique_id,
        c.customer_id,
        c.customer_city,
        c.customer_state,

        o.order_id,
        o.order_status,
        o.purchase_datetime,

        p.total_payment_value

    FROM {{ ref('stg_customers') }} c

    LEFT JOIN {{ ref('stg_orders') }} o
        ON c.customer_id = o.customer_id

    LEFT JOIN (
        SELECT
            order_id,
            SUM(payment_value) AS total_payment_value
        FROM {{ ref('stg_order_payments') }}
        GROUP BY order_id
    ) p
        ON o.order_id = p.order_id

),

customer_metrics AS (

    SELECT
        customer_unique_id,

        MIN(customer_city) AS customer_city,
        MIN(customer_state) AS customer_state,

        MIN(purchase_datetime) AS first_order_datetime,
        MAX(purchase_datetime) AS last_order_datetime,

        COUNT(DISTINCT order_id) AS total_orders,

        SUM(total_payment_value) AS total_spent,

        AVG(total_payment_value) AS average_order_value,

        COUNT(DISTINCT CASE
            WHEN order_status = 'delivered'
            THEN order_id
        END) AS delivered_orders,

        COUNT(DISTINCT CASE
            WHEN order_status IN ('canceled', 'unavailable')
            THEN order_id
        END) AS failed_orders

    FROM customer_orders
    GROUP BY customer_unique_id

)

SELECT *
FROM customer_metrics
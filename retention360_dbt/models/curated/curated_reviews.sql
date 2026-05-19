WITH reviews AS (

    SELECT *
    FROM {{ ref('stg_order_reviews') }}

),

orders AS (

    SELECT *
    FROM {{ ref('stg_orders') }}

)

SELECT
    r.review_id,
    r.order_id,

    o.customer_id,
    o.order_status,
    o.purchase_datetime,
    o.customer_delivery_datetime,
    o.estimated_delivery_datetime,

    r.review_score,
    r.review_comment_title,
    r.review_comment_message,
    r.review_creation_datetime,
    r.review_answer_datetime,

    DATEDIFF(
        day,
        o.purchase_datetime,
        o.customer_delivery_datetime
    ) AS delivery_days,

    DATEDIFF(
        day,
        o.estimated_delivery_datetime,
        o.customer_delivery_datetime
    ) AS delivery_delay_days,

    CASE
        WHEN o.customer_delivery_datetime > o.estimated_delivery_datetime
        THEN TRUE
        ELSE FALSE
    END AS is_late_delivery

FROM reviews r

LEFT JOIN orders o
    ON r.order_id = o.order_id
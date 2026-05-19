SELECT
    DATE_TRUNC('month', review_creation_datetime) AS review_month,

    COUNT(DISTINCT review_id) AS total_reviews,
    COUNT(DISTINCT order_id) AS reviewed_orders,

    AVG(review_score) AS average_review_score,

    SUM(CASE WHEN review_score >= 4 THEN 1 ELSE 0 END) AS positive_reviews,
    SUM(CASE WHEN review_score <= 2 THEN 1 ELSE 0 END) AS negative_reviews,

    SUM(CASE WHEN is_late_delivery = TRUE THEN 1 ELSE 0 END) AS late_delivery_reviews,

    AVG(delivery_days) AS average_delivery_days,
    AVG(delivery_delay_days) AS average_delivery_delay_days

FROM {{ ref('curated_reviews') }}

GROUP BY 1
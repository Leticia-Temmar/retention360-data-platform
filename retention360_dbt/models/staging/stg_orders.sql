SELECT
    order_id,
    customer_id,

    LOWER(order_status) AS order_status,

    TRY_TO_TIMESTAMP(order_purchase_timestamp) AS purchase_datetime,

    TRY_TO_TIMESTAMP(order_approved_at) AS approved_datetime,

    TRY_TO_TIMESTAMP(order_delivered_carrier_date) AS carrier_delivery_datetime,

    TRY_TO_TIMESTAMP(order_delivered_customer_date) AS customer_delivery_datetime,

    TRY_TO_TIMESTAMP(order_estimated_delivery_date) AS estimated_delivery_datetime

FROM {{ source('raw', 'raw_orders') }}
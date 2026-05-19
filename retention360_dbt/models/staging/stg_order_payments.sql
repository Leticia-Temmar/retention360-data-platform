SELECT
    order_id,

    TRY_TO_NUMBER(payment_sequential)
    AS payment_sequential,

    LOWER(payment_type)
    AS payment_type,

    TRY_TO_NUMBER(payment_installments)
    AS payment_installments,

    TRY_TO_DECIMAL(payment_value, 10, 2)
    AS payment_value

FROM {{ source('raw', 'raw_order_payments') }}
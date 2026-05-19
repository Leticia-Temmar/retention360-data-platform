SELECT
    customer_id,

    customer_unique_id,

    TRY_TO_NUMBER(customer_zip_code_prefix)
    AS customer_zip_code_prefix,

    LOWER(customer_city)
    AS customer_city,

    UPPER(customer_state)
    AS customer_state

FROM {{ source('raw', 'raw_customers') }}
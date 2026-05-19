SELECT
    seller_id,

    TRY_TO_NUMBER(seller_zip_code_prefix)
    AS seller_zip_code_prefix,

    LOWER(seller_city)
    AS seller_city,

    UPPER(seller_state)
    AS seller_state

FROM {{ source('raw', 'raw_sellers') }}
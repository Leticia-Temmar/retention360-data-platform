SELECT
    review_id,

    order_id,

    TRY_TO_NUMBER(review_score)
    AS review_score,

    review_comment_title,

    review_comment_message,

    TRY_TO_TIMESTAMP(review_creation_date)
    AS review_creation_datetime,

    TRY_TO_TIMESTAMP(review_answer_timestamp)
    AS review_answer_datetime

FROM {{ source('raw', 'raw_order_reviews') }}
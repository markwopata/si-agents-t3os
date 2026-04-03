with source as (

    select * from {{ source('analytics_credit_card', 'receipt_ocr_itemization_fraud') }}

),

renamed as (

    select

        -- ids
        purchase_id,
        market_id,

        -- strings
        image_url,
        item_text,
        category,
        line_notes,
        fraud_reasoning,

        -- numerics
        line_idx,
        amount,
        fraud_confidence,

        -- booleans
        fraud_flag,
        need_further_review,

        -- timestamps
        submitted_at,
        upload_date

    from source

)

select * from renamed

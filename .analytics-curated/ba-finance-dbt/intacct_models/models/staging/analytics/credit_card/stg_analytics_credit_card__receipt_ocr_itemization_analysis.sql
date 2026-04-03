with source as (

    select * from {{ source('analytics_credit_card', 'receipt_ocr_itemization_analysis') }}

),

renamed as (

    select

        -- grain
        purchase_id,
        image_url,

        -- ids
        market_id,

        -- strings
        ocr_data_raw,
        evaluation_reasoning,
        transaction_merchant_name,
        image_evaluation,

        -- numerics
        receipt_confidence,
        handwritten_confidence,
        image_quality,

        -- booleans
        receipt_flag,
        handwritten_flag,

        -- dates
        -- timestamps        
        submitted_at,
        upload_date

    from source

)

select * from renamed

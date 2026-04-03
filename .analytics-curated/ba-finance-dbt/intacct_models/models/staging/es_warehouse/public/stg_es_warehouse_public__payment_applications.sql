with source as (

    select * from {{ source('es_warehouse_public', 'payment_applications') }}

),

renamed as (

    select

        -- ids
        payment_application_id,
        payment_id,
        invoice_id,
        user_id,
        reversed_by_user_id,
        payment_application_reversal_reason_id,

        -- strings
        reversal_reason,

        -- numerics
        amount,

        -- dates
        date,
        reversed_date,

        -- timestamps
        _es_update_timestamp

    from source

)

select * from renamed

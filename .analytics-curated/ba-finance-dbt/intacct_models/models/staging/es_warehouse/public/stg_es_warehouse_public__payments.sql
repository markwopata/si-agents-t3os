with source as (

    select * from {{ source('es_warehouse_public', 'payments') }}

),

renamed as (

    select

        -- ids
        payment_id,
        payment_method_id,
        user_id,
        invoice_id,
        xero_id,
        created_by_user_id,
        payment_method_type_id,
        company_id,
        branch_id,
        order_id,
        bank_account_id,
        stripe_id,

        -- strings
        reference,
        result,
        'https://admin.equipmentshare.com/#/home/payments/' || payment_id as url_admin,

        -- numerics
        status,
        amount_remaining,
        check_number,
        amount,

        -- booleans
        entered_as_prepayment,

        -- dates
        date_created,

        -- timestamps
        _es_update_timestamp,
        payment_date

    from source

)

select * from renamed

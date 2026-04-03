with source as (
    select * from {{ source('analytics_commission', 'commission_transaction_types') }}
),

renamed as (
    select
        commission_transaction_key,
        commission_transaction_type_id,
        credit_transaction_type_id,
        transaction_name,
        transaction_group,
        transaction_description
    from source
)

select * from renamed

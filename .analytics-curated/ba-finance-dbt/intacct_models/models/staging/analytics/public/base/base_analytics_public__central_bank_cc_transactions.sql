with source as (
      select * from {{ source('analytics_public', 'central_bank_cc_transactions') }}
)

, renamed as (
    select

        -- ids
        employee_id
        , account_transaction_id::text as transaction_id

        -- strings
        , first_name
        , last_name
        , concat(first_name, ' ', last_name) as full_name
        , mcc_description as mcc
        , 'central_bank' as card_type
        , status_reason_desc as status
        , merchant_name
        , mcc::text as mcc_code
        , card_no as card_number
        , reference_no as reference_number

        -- numerics
        , transaction_amt as transaction_amount

        -- booleans
        , FALSE as is_bypass_verification

        -- dates
        , transaction_dt::date as transaction_date

    from source
)

select * from renamed

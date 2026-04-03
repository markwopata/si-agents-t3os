with source as (

    select * from {{ source('lease_accelerator', 'payment_schedule_api_download') }}

),

renamed as (

    select
        -- grain
        schedule_number,
        payment_date,
        _es_update_timestamp,

        -- strings
        ledger_code,
        case
            when ledger_code = '124' then 'Finance'
            when ledger_code = '164' then 'Operating'
        end as ledger_category,
        funder,
        bu,
        pr_number,
        po_number,
        accounting_classification,
        coa_signed,
        status,
        lease_type,
        lease_genre,
        term,
        payment_frequency,
        transactional_currency,
        last_renewal,
        renewal_term,
        mos_left,

        -- numerics
        coalesce(payment_amount, 0) as payment_amount,
        current_lease_payment_reporting_currency_,
        current_lease_payment_transactional_currency_,
        amount_financed_reporting_currency_,
        amount_financed_transactional_currency_,

        -- booleans
        -- dates
        period_start_date,
        original_end_date,
        booking_ledger_date,
        lease_start_date,
        effective_end_date,      

    from source

)

select * from renamed
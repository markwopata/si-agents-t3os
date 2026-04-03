with payment_schedule as (

    select * from {{ ref('base_analytics_lease_accelerator__payment_schedule_api_download')}}

)

, renamed as (

    select
        -- grain
        schedule_number,
        payment_date,
        _es_update_timestamp,

        -- strings
        ledger_code,
        ledger_category,
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
        payment_amount,
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
        effective_end_date        

    from payment_schedule
    qualify dense_rank() over(partition by ledger_code order by _es_update_timestamp desc) = 1

)

select * from renamed

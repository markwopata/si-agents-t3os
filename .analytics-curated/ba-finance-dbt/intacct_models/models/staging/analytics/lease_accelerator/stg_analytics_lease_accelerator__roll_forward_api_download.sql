with source as (

    select * from {{ ref('base_analytics_lease_accelerator__roll_forward_api_download') }}

),

renamed as (

    select

        -- ids
        ledgerentrysubid,
        entity_id,
        gl_account_number,
        market_id,

        -- strings
        accountdescription,
        schedule,
        comments,
        entry_type,
        affected_component,
        triggering_event,
        event_details,
        je_type,
        posting_code,
        jeshortdesc,
        status,
        reporting_currency,
        functional_currency,
        transactional_currency,

        -- numerics
        transactional_dr,
        transactional_cr,
        transactional_net,
        functional_dr,
        functional_cr,
        functional_net,
        reporting_dr,
        reporting_cr,
        reporting_net,
        ledger_code,

        -- dates
        ledger_date,
        fx_conversion_date,

        -- timestamps
        _es_update_timestamp

    from source
    qualify dense_rank() over(order by _es_update_timestamp desc) = 1

)

select * from renamed

with source as (

    select * from {{ source('lease_accelerator', 'roll_forward_api_download') }}

),

renamed as (

    select

        -- ids
        ledgerentrysubid,
        segment1 as entity_id,
        segment2 as gl_account_number,
        segment3 as market_id,

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
        coalesce(transactional_dr, 0) as transactional_dr,
        coalesce(transactional_cr, 0) as transactional_cr,
        coalesce(transactional_net, 0) as transactional_net,
        coalesce(functional_dr, 0) as functional_dr,
        coalesce(functional_cr, 0) as functional_cr,
        coalesce(functional_net, 0) as functional_net,
        coalesce(reporting_dr, 0) as reporting_dr,
        coalesce(reporting_cr, 0) as reporting_cr,
        reporting_net,
        ledger_code,

        -- dates
        ledger_date,
        fx_conversion_date,

        -- timestamps
        _es_update_timestamp

    from source

)

select * from renamed

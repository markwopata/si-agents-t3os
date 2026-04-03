with base as (

    select * from {{ ref('base_analytics_lease_accelerator__bu_asset_api_download') }}

)

, filter_to_most_recent_run as (

    select

        -- ids
        las_asset_id,
        admin_asset_id, -- naming this asset_code to match values in asset4000 system (from lease assets acounting to fixed assets accounting)
        market_id,
        ledger_code,

        -- strings
        ledger_category,
        host_name,
        business_unit,
        entity,
        funder,
        asset_type,
        asset_type,
        currency,
        renewal_term,
        status,
        lease_type,
        payment_schedule,
        product_number,
        manufacturer,
        description,
        address,
        city,
        state,
        country,
        asset_owner,
        asset_tag,
        vendor,
        lease_genre,

        -- numerics
        lease,
        current_fx_rate,
        fx_rate_at_lsd,
        asset_cost_local,
        asset_rent_local,
        allocated_cost_local,
        allocated_rent_local,
        asset_cost_reporting_currency,
        asset_rent_reporting_currency,
        allocated_cost_reporting_currency,
        allocated_rent_reporting_currency,
        term,
        months_remaining,
        original_lease_rate_factor,
        serial_number,
        asset_reference_number,
        postal_code,

        -- booleans

        -- dates
        date_entered,
        booking_ledger_date,
        commencement_date,
        original_end_date,
        last_renewal,
        effective_end_date,
        
        -- timestamps
        _es_update_timestamp

    from base
    qualify dense_rank() over(partition by ledger_code order by _es_update_timestamp desc) = 1 -- filtering to the most recent report run for each report (finance vs operating leases)

)

select * from filter_to_most_recent_run

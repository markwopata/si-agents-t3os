with source as (

    select * from {{ source('lease_accelerator', 'bu_asset_api_download') }}

),

renamed as (

    select

        -- ids
        asset_id as las_asset_id,
        round(coalesce(nullif(host_name, 'nan'), 0),0) as admin_asset_id, -- naming this asset_code to match values in asset4000 system (from lease assets acounting to fixed assets accounting)
        ledger_code,
        
        -- strings
        case
            when ledger_code = '124' then 'Finance'
            when ledger_code = '164' then 'Operating'
        end as ledger_category,

        host_name,
        business_unit,
        entity,
        funder,
        asset_type,
        gl as asset_type,
        transactional_currency as currency,
        renewal_term,
        status,
        lease_type,
        advarr as payment_schedule,
        product_ as product_number,
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
        cc as market_id,
        schedule_ as lease,
        current_fx_rate,
        fx_rate_at_lsd,
        asset_cost_transactional_currency as asset_cost_local,
        asset_rent_transactional_currency as asset_rent_local,
        allocated_cost_transactional_currency as allocated_cost_local,
        allocated_rent_transactional_currency as allocated_rent_local,
        asset_cost_reporting_currency,
        asset_rent_reporting_currency,
        allocated_cost_reporting_currency,
        allocated_rent_reporting_currency,
        term,
        mos_remaining as months_remaining,
        original_lrf as original_lease_rate_factor,
        serial_ as serial_number,
        ref_ as asset_reference_number,
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

    from source

)

select * from renamed

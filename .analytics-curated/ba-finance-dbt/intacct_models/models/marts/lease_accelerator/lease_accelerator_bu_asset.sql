with bu_asset_report as (

    select * from {{ ref('stg_analytics_lease_accelerator__bu_asset_api_download') }}

)

, assets_aggregate as (

    select * from {{ ref('stg_es_warehouse_public__assets_aggregate')}}

)

, join_assets_aggregate as (

    select
        -- ids
        bu.las_asset_id,
        bu.market_id,
        bu.ledger_code,
        
        -- strings
        bu.ledger_category,
        bu.funder,
        bu.asset_type,
        bu.status,
        bu.lease_type,
        bu.payment_schedule,
        bu.product_number,
        bu.description,
        bu.admin_asset_id, -- naming this asset_code to match values in asset4000 system (from lease assets acounting to fixed assets accounting)
        bu.asset_owner,
        bu.asset_tag,
        bu.vendor,
        ag.make,
        ag.model,
        ag.class,

        -- numerics
        bu.lease,
        bu.term,
        bu.months_remaining,
        bu.original_lease_rate_factor,
        bu.serial_number,
        bu.asset_reference_number,
        bu.postal_code,

        -- booleans

        -- dates
        bu.date_entered,
        bu.original_end_date,
        bu.last_renewal,
        bu.effective_end_date,
        ag.first_rental_date,

        -- timestamps
        bu._es_update_timestamp

    from bu_asset_report bu
    left join assets_aggregate ag
        on bu.las_asset_id = ag.asset_id

)

select * from join_assets_aggregate

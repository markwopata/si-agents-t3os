with ledger_export_assets as (
    
    select * from {{ ref('int_ledger_export_journal_entries_pivoted_to_assets') }}

)

, bu_asset_report as (

    select * from {{ ref('stg_analytics_lease_accelerator__bu_asset_api_download') }}

)

, ledger_export as (

    select  
        asset_number
        , schedule
        , gl_account_number
        , account_description
        , _es_update_timestamp
        , sum(net_amount) as net_amount
    from {{ ref('stg_analytics_lease_accelerator__ledger_export_api_download') }}
    group by 
        all

)

, assets_aggregate as (

    select * from {{ ref('stg_es_warehouse_public__assets_aggregate')}}

)

, add_asset_id_correction as (
    select
        -- ids
        l.asset_number
        , bu.admin_asset_id
        , bu.asset_reference_number
        , bu.las_asset_id

        -- strings
        , l.account_description
        , ag.make
        , ag.model
        , ag.class
        , l.comments
        , le.gl_account_number
        , le.schedule

        -- booleans

        -- numerics
        , l.net_amount
        , l.market_id
        , bu.serial_number

        -- dates
        , ag.first_rental_date
        , bu.commencement_date

        -- timestamps
        , l.ledger_date

    from ledger_export_assets l
    left join bu_asset_report bu
        on l.asset_number = bu.las_asset_id
    inner join assets_aggregate ag
        on l.asset_number = ag.asset_id
    inner join ledger_export le
        on l.asset_number = le.asset_number
        and l.account_description = le.account_description
        and l.net_amount = le.net_amount -- due to the nature of the JE data, had to join on net_amount to prevent fan-out.


)

select * from add_asset_id_correction

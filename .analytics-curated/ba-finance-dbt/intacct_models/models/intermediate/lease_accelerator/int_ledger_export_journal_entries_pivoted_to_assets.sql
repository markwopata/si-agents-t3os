with je_to_assets as (
    select
        asset_number,
        account_description,
        sum(net_amount) as net_amount,
        max(ledger_date) as ledger_date,
        array_agg(distinct market_id) within group (order by market_id asc) as market_id,
        array_agg(distinct comments) within group (order by comments asc) as comments
    from {{ ref('stg_analytics_lease_accelerator__ledger_export_api_download') }}
    group by 
        all
)

select 
    j.asset_number,
    j.account_description,
    j.net_amount,
    j.ledger_date,
    j.market_id,
    j.comments
from je_to_assets j

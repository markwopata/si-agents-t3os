select
    c.asset_code
    , c.depreciation_date
    , c.book_code
    , c._fivetran_deleted
    , sum(c.period_depreciation_expense) as period_depreciation_expense
    , sum(c.nbv) as nbv
    , sum(c.oec) as oec
from {{ ref('stg_analytics_asset4000_dbo__fa_costs') }} c 
inner join {{ ref('stg_analytics_asset4000_dbo__fa_transfers') }} t
    on c.asset_code = t.asset_code
    and c.transfer_year = t.transfer_year
    and c.transfer_per_sequence = t.transfer_per_sequence
    and not t._fivetran_deleted
group by 
    all

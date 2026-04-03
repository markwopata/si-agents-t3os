select
    p.branchid as bt_branch_id,
    p.changedatetime as change_datetime,
    p.productid as product_id,
    p.averagecostprice as average_cost_price,
    p.lastcostprice as last_cost_price,
    p.standardbuyprice as standard_buy_price,
    p.stockperid as stock_per_id,
    p.buyperid as buy_per_id,
    p.standardsellprice as standard_sell_price,
    p.sellperid as sell_per_id,
    p.lastcostperid as last_cost_per_id,
    p.lastcostpricewithadditional as last_cost_price_with_additional,
    p.averagecostpricewithadditional as average_cost_price_with_additional,
    p._fivetran_deleted as _fivetran_deleted,
    p._fivetran_synced as _fivetran_synced
from {{ source('analytics_bt_dbo', 'productpricehistory') }} as p

select
    s._fivetran_id,
    s.totalreportingcost as total_reporting_cost,
    s.productbatchid as product_batch_id,
    s.stockvaluationid as stock_valuation_id,
    s.valuationdate as valuation_date,
    s.stockunitcost as stock_unit_cost,
    s.standardbuyunitcost as standard_buy_unit_cost,
    s.stockquantity as stock_quantity,
    s.stockperid as stock_per_id,
    s.productid as product_id,
    s.branchid as bt_branch_id,
    s.stockvaluation as stock_valuation,
    s.standardbuyperid as standard_buy_per_id,
    s._fivetran_deleted,
    s._fivetran_synced
from {{ source('analytics_bt_dbo', 'stockvaluationdata') }} as s

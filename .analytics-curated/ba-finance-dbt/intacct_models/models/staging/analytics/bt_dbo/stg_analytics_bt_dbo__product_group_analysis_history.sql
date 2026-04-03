select
    p.productgroupanalysishistoryid as product_group_analysis_history_id,
    p.productgroupid as product_group_id,
    p.calculateddatetime as calculated_datetime,
    p.fullstockturn as full_stock_turn,
    p.periodsanalysed as periods_analysed,
    p.gmroi as gmroi,
    p.branchid as bt_branch_id,
    p.fullstockage as full_stock_age,
    p._fivetran_deleted as _fivetran_deleted,
    p._fivetran_synced as _fivetran_synced
from {{ source('analytics_bt_dbo', 'productgroupanalysishistory') }} as p

select
    p.branchid as bt_branch_id,
    p.productgroupid as product_group_id,
    p.fullstockturn as full_stock_turn,
    p.calculateddatetime as calculated_datetime,
    p.gmroi as gmroi,
    p.periodsanalysed as periods_analysed,
    p.fullstockage as full_stock_age,
    p._fivetran_deleted as _fivetran_deleted,
    p._fivetran_synced as _fivetran_synced
from {{ source('analytics_bt_dbo', 'productgroupanalysis') }} as p

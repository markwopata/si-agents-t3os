select
    p.producttype as product_type_id,
    p.name as product_type_name,
    p._fivetran_deleted,
    p._fivetran_synced
from {{ source('analytics_bt_dbo', 'producttype') }} as p

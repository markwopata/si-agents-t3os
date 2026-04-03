select
    date,
    bt_branch_id,
    market_id,
    market_name,
    revenue
from {{ source('analytics_gs', 'materials_pre_acquisition_revenue') }}

select
    revenue.market_id,
    revenue.bt_branch_id,
    revenue.market_name,
    'Pre-Acquisition Revenue' as description,
    revenue.revenue as total_amount,
    revenue.date as datetime_created,
    'Manual' as line_type
from {{ ref ('stg_analytics_gs__pre_acquisition_materials') }} as revenue

select
    branch_id as bt_branch_id,
    branch_code as bt_branch_code,
    market_id,
    market_name,
    bt_start_date,
    square_footage
from {{ source('analytics_gs', 'materials_branch') }}

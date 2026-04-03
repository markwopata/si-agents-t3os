select
    work_order_id,
    work_order_date_billed,
    major_asset_repair_requests_id as major_asset_repair_request_id,
    created_date,
    effective_date,
    depreciation_flag, -- meets criteria for capitalization, or was overridden & approved for capitalization
    is_dispute_review, -- flagged for dispute review by fleet team
    disputed,  -- flagged as disputed by gm
    depreciation_period,
    is_current,
    t3_labor_cost,
    t3_part_cost,
    outside_service_cost,
    combined_work_order_cost,
    branch_id,
    asset_id,
    user_id,
    created_by,
    purchase_orders,
    failed_conditions, -- what criteria did the request fail to meet (if any)
    disputed_note,
    dispute_note

from {{ source('analytics_service', 'major_asset_repair_requests') }}

-- EXPENSE REVERSALS FOR STATIC BRANCH EARNINGS --
with parts_cap as (
    select
        cap_schedule.major_asset_repair_request_id,
        cap_schedule.work_order_id,
        cap_schedule.branch_id as mkt_id,
        cap_schedule.asset_id,
        cap_schedule.major_asset_repair_request_effective_date as gl_date,
        concat(
            'Asset Repair Expense Capitalization: Asset: ', cap_schedule.asset_id, ' Work Order# ',
            cap_schedule.work_order_id, ' PO#s ',
            coalesce(cap_schedule.purchase_orders_linked_to_work_order, ''),
            ' WO Description: ', cap_schedule.work_order_description
        ) as descr,
        'GDDA' as acctno,
        round(cap_schedule.total_es_part_amount, 2) as amount
    from {{ ref('int_major_asset_repair_capitalization_schedule') }} as cap_schedule
    where cap_schedule.total_es_part_amount != 0 -- only grabbing records that are not zero
        and cap_schedule.depreciation_month_number = 1 --only reverse expenses in the first month
),

labor_cap as (
    select
        cap_schedule.major_asset_repair_request_id,
        cap_schedule.work_order_id,
        cap_schedule.branch_id as mkt_id,
        cap_schedule.asset_id,
        cap_schedule.major_asset_repair_request_effective_date as gl_date,
        concat(
            'Asset Repair Expense Capitalization: Asset: ', cap_schedule.asset_id, ' Work Order# ',
            cap_schedule.work_order_id, ' PO#s ',
            coalesce(cap_schedule.purchase_orders_linked_to_work_order, ''),
            ' WO Description: ', cap_schedule.work_order_description
        ) as descr,
        '6310' as acctno,
        round(cap_schedule.total_es_labor_amount, 2) as amount
    from {{ ref('int_major_asset_repair_capitalization_schedule') }} as cap_schedule
    where cap_schedule.total_es_labor_amount != 0 -- only grabbing records that are not zero
        and cap_schedule.depreciation_month_number = 1 --only reverse expenses in the first month
),

os_labor_cap as (
    select
        cap_schedule.major_asset_repair_request_id,
        cap_schedule.work_order_id,
        cap_schedule.branch_id as mkt_id,
        cap_schedule.asset_id,
        cap_schedule.major_asset_repair_request_effective_date as gl_date,
        concat(
            'Asset Repair Expense Capitalization: Asset: ', cap_schedule.asset_id,
            ' Work Order# ',
            cap_schedule.work_order_id, ' PO#s ',
            coalesce(cap_schedule.purchase_orders_linked_to_work_order, ''),
            ' WO Description: ', cap_schedule.work_order_description
        ) as descr,
        '6302' as acctno,
        round(cap_schedule.total_service_os_labor_cap_amount, 2) as amount
    from {{ ref('int_major_asset_repair_capitalization_schedule') }} as cap_schedule
    where cap_schedule.total_service_os_labor_cap_amount != 0 -- only grabbing records that are not zero
        and cap_schedule.depreciation_month_number = 1 --only reverse expenses in the first month
),

combined_cap as ( -- union all three accounts together
    select *
    from parts_cap
    union all
    select *
    from labor_cap
    union all
    select *
    from os_labor_cap
)
-- format data to integrate with static model
select
    cc.mkt_id,
    m.child_market_name as mkt_name,
    pbm.display_name as type,
    "GROUP" as code,
    pbm.revexp,
    right("GROUP", length("GROUP") - 3) as dept,
    null as pr_type,
    pbm.sage_name as gl_acct,
    acctno,
    null as ar_type,
    descr,
    gl_date,
    cc.work_order_id as doc_no,
    concat(cc.major_asset_repair_request_id, '-', cc.work_order_id, '-', cc.asset_id, '-', cc.acctno) as pk,
    null as url_sage,
    null as url_yooz,
    concat('https://app.estrack.com/#/service/work-orders/', cc.work_order_id, '/updates') as url_admin,
    null as url_track,
    coalesce((amount * 1), 0) as amount, --amount is positive as we are reversing an expense
    null as type2,
    object_construct(
        'asset_id', cc.asset_id,
        'work_order_id', cc.work_order_id,
        'major_asset_repair_request_id', cc.major_asset_repair_request_id
    ) as metadata
from combined_cap as cc
    inner join {{ ref("market") }} as m
        on cc.mkt_id = m.child_market_id::varchar
    inner join {{ ref("stg_analytics_gs__plexi_bucket_mapping") }} as pbm
        on cc.acctno = pbm.sage_gl

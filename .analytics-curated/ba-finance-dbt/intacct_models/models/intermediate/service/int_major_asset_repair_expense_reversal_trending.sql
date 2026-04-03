-- EXPENSE REVERSALS FOR TRENDING --
with parts_cap as ( --all parts expenses
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

labor_cap as ( --all labor expense
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

os_labor_cap as ( --all outside service labor expense
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

-- format data to integrate with trending model
select
    cc.mkt_id,
    acctno as account_number,
    'asset_id|mkt_id|major_asset_repair_request_id|account_number' as transaction_number_format,
    cc.asset_id || '|' || cc.mkt_id || '|' || cc.major_asset_repair_request_id || '|' || cc.acctno as transaction_number,
    descr,
    gl_date::date as gl_date,
    'Asset Repair Expense Adjustment' as document_type,
    concat(cc.major_asset_repair_request_id, '-', cc.work_order_id, '-', cc.asset_id) as document_number,
    null as url_sage,
    null as url_concur,
    null as url_admin,
    concat('https://app.estrack.com/#/service/work-orders/', cc.work_order_id, '/updates') as url_t3,
    coalesce((amount * 1), 0) as amount, --amount is positive as we are reversing an expense
    object_construct(
        'asset_id', asset_id,
        'work_order_id', work_order_id,
        'major_asset_repair_request_id', major_asset_repair_request_id
    ) as additional_data,
    'ANALYTICS.INTACCT_MODELS' as source,
    'Asset Repair Expense Reversal Trending' as load_section,
    'int_major_asset_repair_expense_reversal_trending' as source_model
from combined_cap as cc
    inner join {{ ref("market") }} as m
        on cc.mkt_id = m.child_market_id::varchar
    inner join {{ ref("stg_analytics_gs__plexi_bucket_mapping") }} as pbm
        on cc.acctno = pbm.sage_gl

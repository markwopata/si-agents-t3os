-- Equipment Repair Capitalizations --
with combined_cap as (
    select
        cap_schedule.major_asset_repair_request_id,
        cap_schedule.work_order_id,
        cap_schedule.branch_id as mkt_id,
        cap_schedule.asset_id,
        MIN(cap_schedule.DEPRECIATION_MONTH_NUMBER)                          as depreciation_month_number,
        cap_schedule.major_asset_repair_request_effective_date as effective_date,
        cap_schedule.scheduled_capitalization_date_adjusted as gl_date,
        concat(
            'Asset Repair Capitalization: Asset# ', cap_schedule.asset_id, ' Work Order# ',
            cap_schedule.work_order_id, ' PO#s ',
            coalesce(cap_schedule.purchase_orders_linked_to_work_order, ''),
            ' WO Description: ', cap_schedule.work_order_description
        ) as descr,
        'IBABB' as acctno, --new account for equipment capitalizations
        round(sum(cap_schedule.monthly_total_cap_amount), 2) as amount
    from {{ ref('int_major_asset_repair_capitalization_schedule') }} as cap_schedule
    where cap_schedule.monthly_total_cap_amount != 0 -- only grabbing records that are not zero
    group by all
)

select
    cc.mkt_id as market_id,
    cc.acctno as account_number,
    ' Repair Request ID | Asset ID | Historical Asset Market | Depreciation Month Number' as transaction_number_format,
    cc.major_asset_repair_request_id || '|' || cc.asset_id || '|' || cc.mkt_id || '|' || cc.depreciation_month_number as transaction_number,
    cc.descr as description,
    cc.gl_date,
    'Asset ID' as document_type,
    cc.asset_id::varchar as document_number,
    null as url_sage,
    null as url_concur,
    'https://admin.equipmentshare.com/#/home/assets/asset/' || cc.asset_id as url_admin,
    'https://app.estrack.com/#/service/work-orders/' || cc.work_order_id as url_t3,
    (cc.amount * -1) as amount, -- changed to negative to reflect capitalization as a expense
    object_construct(
        'asset_id', cc.asset_id,
        'work_order_id', cc.work_order_id,
        'major_asset_repair_request_id', cc.major_asset_repair_request_id
    ) as additional_data,
    'ANALYTICS' as source,
    'Equipment Repair Capitalization' as load_section,
    'int_major_asset_repair_monthly_capitalization_trending' as source_model
from combined_cap as cc

--Equipment Repair Capitalizations --
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
    concat(cc.major_asset_repair_request_id, '-', cc.work_order_id, '-', cc.asset_id, '-', cc.depreciation_month_number) as pk,
    cc.mkt_id,
    m.market_name as mkt_name,
    pbm.display_name as type,
    pbm."GROUP" as code,
    pbm.revexp,
    right(pbm."GROUP", length(pbm."GROUP") - 3) as dept,
    null as pr_type,
    pbm.sage_name as gl_acct,
    acctno,
    null as ar_type,
    descr,
    gl_date,
    cc.work_order_id as doc_no,
    null as url_sage,
    null as url_yooz,
    concat('https://app.estrack.com/#/service/work-orders/', cc.work_order_id, '/updates') as url_admin,
    null as url_track,
    amount * -1 as amount, -- changed to negative to reflect capitalization as a expense
    null as type2,
    object_construct(
        'asset_id', asset_id,
        'work_order_id', work_order_id,
        'major_asset_repair_request_id', major_asset_repair_request_id
    ) as metadata
from combined_cap as cc
    left join {{ ref("market") }} as m
        on cc.mkt_id = m.child_market_id::varchar
    left join {{ ref("stg_analytics_gs__plexi_bucket_mapping") }} as pbm
        on cc.acctno = pbm.sage_gl
        {# left join {{ ref('int_major_asset_repair_capitalization_schedule') }} as cap_schedule
            on cc.major_asset_repair_request_id = cap_schedule.major_asset_repair_request_id
                and cc.work_order_id = cap_schedule.work_order_id
                and cap_schedule.scheduled_capitalization_date_adjusted = cc.gl_date #}

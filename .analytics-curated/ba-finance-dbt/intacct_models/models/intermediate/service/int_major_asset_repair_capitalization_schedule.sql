with base_requests as ( -- consistently pulls records from staging for use in building cap schedule 
    select marr.*
    from {{ ref('stg_analytics_service__major_asset_repair_requests') }} as marr
    -- only requests that meet capitalization criteria or were overridden & approved for capitalization
    where marr.depreciation_flag = true
    qualify row_number() over (
            partition by marr.work_order_id -- pulling first request for each work order
            order by marr.effective_date asc, marr.created_date asc
        ) = 1
),

periods_per_wo as ( -- creating a list of months to depreciate for each work order, to be joined back to main table to create monthly schedule rows
    select
        br.work_order_id,
        t.series::date as month_date,
        row_number() over (
            partition by br.work_order_id
            order by t.series::date
        ) as month_num
    from base_requests as br
        cross join table(
            -- generate list of months from effective date to effective date + depreciation periods for each work order
            es_warehouse.public.generate_series(
                date_trunc('month', br.effective_date)::timestamp_tz,
                date_trunc('month', dateadd(month, br.depreciation_period - 1, br.effective_date))::timestamp_tz,
                'month'
            )
        ) as t
)

select
    marr.major_asset_repair_request_id,
    marr.work_order_id,
    wo.description as work_order_description,
    date_trunc('month', m.month_date)::date as scheduled_capitalization_date,
    sd.sale_month::date as sale_month,
    coalesce(sd.sale_month::date, scheduled_capitalization_date::date) as scheduled_capitalization_date_adjusted,
    round(coalesce(marr.t3_labor_cost, 0), 2) as total_es_labor_amount,
    round(coalesce(marr.t3_labor_cost, 0) / nullif(marr.depreciation_period, 0), 2) as monthly_total_es_labor_amount,
    round(coalesce(marr.t3_part_cost, 0), 2) as total_es_part_amount,
    round(coalesce(marr.t3_part_cost, 0) / nullif(marr.depreciation_period, 0), 2) as monthly_total_es_part_amount,
    marr.purchase_orders as purchase_orders_linked_to_work_order,
    round(coalesce(marr.outside_service_cost, 0), 2) as total_service_os_labor_cap_amount,
    round(coalesce(marr.outside_service_cost, 0) / nullif(marr.depreciation_period, 0), 2)
        as monthly_service_os_labor_cap_amount,
    round(coalesce(marr.combined_work_order_cost, 0), 2) as total_capitalization_amount,
    round(coalesce(marr.combined_work_order_cost, 0) / nullif(marr.depreciation_period, 0), 2)
        as monthly_total_cap_amount,
    wo.date_updated::timestamp_ntz as work_order_date_updated,
    marr.work_order_date_billed::timestamp_ntz as work_order_date_billed,
    marr.created_date::timestamp_ntz as major_asset_repair_request_created_date,
    marr.effective_date::timestamp_ntz as major_asset_repair_request_effective_date,
    marr.asset_id,
    marr.branch_id, -- equivalent to market_id or mkt_id, joining to market table for market name in final model
    marr.user_id,
    concat(u.first_name, ' ', u.last_name) as major_asset_repair_request_created_name,
    marr.depreciation_period as requested_depreciation_periods,
    m.month_num as depreciation_month_number
from base_requests as marr
    left join {{ ref("stg_es_warehouse_work_orders__work_orders") }} as wo
        on marr.work_order_id::varchar = wo.work_order_id::varchar
    left join {{ ref("stg_es_warehouse_public__users") }} as u
        on marr.user_id::varchar = u.user_id::varchar
    inner join periods_per_wo as m
        on marr.work_order_id = m.work_order_id
            and m.month_date < dateadd(month, marr.depreciation_period, marr.effective_date)
    left join {{ ref('int_major_asset_repair_asset_ownership_date') }} as sd
        on marr.asset_id = sd.asset_id
            -- only adjust if sale month is >= scheduled cap month
            and date_trunc('month', m.month_date)::date >= sd.sale_month::date
            and date_trunc(month, sd.sale_month) >= date_trunc(month, marr.effective_date) -- sale date must be after effective date


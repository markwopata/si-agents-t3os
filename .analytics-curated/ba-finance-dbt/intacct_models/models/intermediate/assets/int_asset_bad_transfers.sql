-- TODO
-- - For first month forgiveness, make sure asset was received. 
--      Business_data_vault is broken right now though.
with first_rsp_month as (
    select
        sar.asset_id,
        date_trunc(month, min(sar.date_start))::date as first_month_in_fleet_date
    from
        {{ ref("stg_es_warehouse_scd__scd_asset_rsp") }} as sar
        inner join {{ ref("stg_es_warehouse_public__markets") }} as m
            on sar.rental_branch_id = m.market_id
        inner join {{ ref("stg_analytics_public__es_companies") }} as ec
            on m.company_id = ec.company_id
                and ec.owned
    group by all
),

market_asset_rsp as (
    select
        sar.asset_id,
        aa.oec,
        m.market_id,
        m.market_name,
        sar.date_start,
        sar.date_end,
        m.branch_earnings_start_month as market_start
    from
        {{ ref("stg_es_warehouse_scd__scd_asset_rsp") }} as sar
        inner join {{ ref("market") }} as m
            on sar.rental_branch_id = m.child_market_id
        inner join {{ ref("stg_es_warehouse_public__assets_aggregate") }} as aa
            on sar.asset_id = aa.asset_id
    where
        sar.date_start != sar.date_end
    order by sar.asset_id, sar.date_start
),

branch_transfers as (
    select
        asset_id,
        oec,
        market_id as from_market_id,
        market_name as from_market_name,
        market_start as from_market_start,
        date_start as from_date_start,
        date_end as from_date_end,
        lead(market_id) over (
            partition by asset_id
            order by date_start
        ) as to_market_id,
        lead(market_name) over (
            partition by asset_id
            order by date_start
        ) as to_market_name,
        lead(market_start) over (
            partition by asset_id
            order by date_start
        ) as to_market_start,
        lead(date_start) over (
            partition by asset_id
            order by date_start
        ) as to_date_start,
        lead(date_end) over (
            partition by asset_id
            order by date_start
        ) as to_date_end
    from market_asset_rsp
),

determine_bad_transfers as (
    select
        bt.asset_id,
        bt.oec,
        frm.first_month_in_fleet_date,
        bt.from_market_id,
        bt.from_market_name,
        datediff(month, bt.from_market_start, bt.from_date_end) + 1 as from_age_at_transfer,
        bt.from_market_start,
        bt.from_date_start,
        bt.from_date_end,
        bt.to_market_id,
        bt.to_market_name,
        datediff(month, bt.to_market_start, bt.to_date_start) + 1 as to_age_at_transfer,
        bt.to_market_start,
        bt.to_date_start,
        bt.to_date_end,
        -- did the asset move from one branch to another in less than 1 day
        (datediff(day, bt.from_date_end, bt.to_date_start) < 2) as is_direct_transfer,
        (
            from_age_at_transfer > 12
            and (
                to_age_at_transfer <= 12 or (
                    to_age_at_transfer is null
                    and bt.to_market_id is not null
                    and bt.to_market_id != 104004 -- Mobile Tools Warehouse
                )
            )
            and is_direct_transfer
        ) as is_bad_transfer
    from branch_transfers as bt
        left join first_rsp_month as frm
            on bt.asset_id = frm.asset_id
),

rental_data as (
    select
        ea.asset_id,
        ea.date_start,
        ea.date_end
    from
        {{ ref("stg_es_warehouse_public__orders") }} as o
        inner join {{ ref("stg_es_warehouse_public__users") }} as u
            on o.user_id = u.user_id
        inner join {{ ref("stg_es_warehouse_public__rentals") }} as r
            on o.order_id = r.order_id
        inner join {{ ref("stg_es_warehouse_public__equipment_assignments") }} as ea
            on r.rental_id = ea.rental_id
    where
    -- These aren't active rentals
        r.rental_status_id not in (
            1, -- Needs Approval
            2, -- Draft
            3, -- Pending
            4, -- Scheduled
            8  -- Cancelled
        )
        and u.company_id not in ({{ es_companies() }}) -- noqa
        and ea.date_start != ea.date_end
),

rental_tied_to_transfer as (
    select
        dbt.*,
        rd.date_start as rental_start_date,
        rd.date_end as rental_end_date,
        row_number() over (
            partition by
                dbt.asset_id, dbt.to_market_id, dbt.to_date_start, dbt.to_date_end
            order by rd.date_start
        ) as rental_order
    from
        determine_bad_transfers as dbt
        left join rental_data as rd
            on dbt.asset_id = rd.asset_id
                and rd.date_start between dbt.to_date_start and dbt.to_date_end
),

asset_sales as (
    select
        -- Use max to cover if the asset was sold, credited, and then resold
        max(i.billing_approved_date) as billing_approved_date,
        li.asset_id
    from
        {{ ref("stg_es_warehouse_public__invoices") }} as i
        left join {{ ref("stg_es_warehouse_public__line_items") }} as li
            on i.invoice_id = li.invoice_id
    where
        li.line_item_type_id in (24, 111, 50, 80, 81, 141, 110)
        and i.billing_approved
        and li.asset_id is not null
    group by all
),

output as (
    select
        rttt.asset_id,
        rttt.oec,
        rttt.first_month_in_fleet_date,
        rttt.from_market_id,
        rttt.from_market_name,
        rttt.from_date_end,
        rttt.from_age_at_transfer,
        rttt.to_market_id,
        rttt.to_market_name,
        rttt.to_age_at_transfer,
        dateadd(month, 12, rttt.to_market_start) as when_market_is_12_months,
        least(
            coalesce(rttt.rental_start_date, '2099-12-31'),
            coalesce(when_market_is_12_months, '2099-12-31'),
            coalesce(rttt.to_date_end, '2099-12-31'),
            coalesce(asl.billing_approved_date, '2099-12-31')
        ) as end_cost_date
    from
        rental_tied_to_transfer as rttt
        left join asset_sales as asl
            on rttt.asset_id = asl.asset_id
                and asl.billing_approved_date between rttt.to_date_start and rttt.to_date_end
    where
        rttt.rental_order = 1
        and rttt.is_direct_transfer
        and rttt.is_bad_transfer
    order by rttt.from_date_start
),

add_time_series as (
    select
        o.*,
        t.series as equipment_charge_date
    from
        output as o
        cross join
            table(
                es_warehouse.public.generate_series(
                    date_trunc(month, dateadd(month, 1, o.from_date_end))::timestamp_tz,
                    o.end_cost_date::timestamp_tz,
                    'month'
                )
            ) as t
)

select
    *,
    oec * {{ var('equip_factor') }} as equipment_charge,
    1 = row_number() over (
        partition by asset_id, from_market_id, from_date_end
        order by equipment_charge_date
    ) as is_first_dump_charge,
    equipment_charge_date::date = first_month_in_fleet_date as is_first_month_forgiven
from
    add_time_series
where
    not to_market_name ilike '%hard down%'
    and not from_market_name ilike '%hard down%'
    and from_market_id != to_market_id

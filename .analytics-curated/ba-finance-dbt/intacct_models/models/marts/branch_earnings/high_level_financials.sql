with oec_cte as (
    select
        m.market_id,
        date_trunc(month, ad.gl_date::date) as gl_date,
        round(sum(ad.oec), 2) as oec,
        round(sum(iff(
            sais.asset_inventory_status in
            (
                'Pending Return',
                'Make Ready',
                'Needs Inspection',
                'Soft Down',
                'Hard Down'
            ),
            ad.oec,
            0
        )), 2) as unavailable_oec,
        round(sum(iff(
            sais.asset_inventory_status in
            ('On Rent'), ad.oec, 0
        )), 2) as on_rent_oec
    from {{ ref('stg_analytics_branch_earnings__asset_detail') }} as ad
        left join {{ ref("stg_es_warehouse_scd__scd_asset_inventory_status") }} as sais
            on
                ad.asset_id = sais.asset_id
                and
                dateadd(
                    nanosecond, -1, last_day(ad.gl_date) + 1
                ) between sais.date_start and sais.date_end
        inner join {{ ref('market') }} as m
            on ad.market_id = m.child_market_id
    -- This filter is not necassary but provides some safety that we don't duplicate
    where
        (
            ad.load_section = 'Static'
            and date_trunc(month, ad.gl_date) <= '{{ last_branch_earnings_published_date() }}'
        )
        or (
            ad.load_section = 'Trending Asset Detail'
            and date_trunc(month, ad.gl_date) > '{{ last_branch_earnings_published_date() }}'
        )
    group by all
),

period_date_series as (
    select
        series::date as period_start_date,
        dateadd(nanosecond, -1, last_day(series) + 1) as period_end_timestamp
    from
        table(
            es_warehouse.public.generate_series(
                '2022-01-01'::timestamp_tz,
                last_day(current_timestamp)::timestamp_tz,
                'month'
            )
        )
),

service_unavailable as (
    select
        date_trunc(month, md.daily_timestamp::date) as gl_date,
        m.market_id,
        sum(case when md.month_end_date is not null then md.rental_fleet_oec else 0 end) as service_total_oec,
        sum(case when md.month_end_date is not null then md.unavailable_oec else 0 end) as service_unavailable_oec,
        sum(md.rental_fleet_oec) as rental_fleet_oec_daily_sum,
        sum(md.unavailable_oec) as unavailable_oec_daily_sum,
        sum(md.oec_on_rent) as oec_on_rent_daily_sum
    from {{ ref('market_level_asset_metrics_daily') }} as md
        inner join {{ ref('market') }} as m
            on md.market_id = m.child_market_id
    group by all
),

earnings_cte as (
    select
        m.market_id,
        date_trunc(month, beds.gl_date) as gl_date,
        round(sum(case when beds.account_number in ('FAAA', 'TAIR', '5000', '5019') then beds.amount else 0 end), 2)
            as rental_revenue,
        round(sum(case when beds.type = 'Delivery Revenues' then beds.amount else 0 end), 2)
            as delivery_revenue,
        -- Do we need this?
        round(sum(case when beds.account_number = '5009' then beds.amount else 0 end), 2)
            as nonintercompany_delivery_revenue,
        round(
            sum(
                case
                    when
                        beds.account_number in ('6014', '6015', '6016', '6019', '6020', '6031')
                        then beds.amount
                    else 0
                end
            ),
            2
        ) as delivery_expense,
        round(
            sum(
                case
                    when
                        beds.type = 'Sales Revenues'
                        then beds.amount
                    else 0
                end
            ),
            2
        ) as sales_revenue,
        round(
            sum(
                case
                    when
                        beds.type = 'Cost of Sales Revenues'
                        then beds.amount
                    else 0
                end
            ),
            2
        ) as sales_expense,
        round(sum(case when beds.revenue_expense_category = 'REV' then beds.amount else 0 end), 2)
            as total_revenue,
        round(
            sum(
                case
                    when
                        beds.account_name ilike any ('%commission%', '%overtime%', '%payroll%')
                        then beds.amount
                    else 0
                end
            ),
            2
        ) as payroll_compensation_expense,
        round(
            sum(
                case
                    when beds.account_name ilike any ('%overtime%', '%payroll%') then beds.amount else 0
                end
            ),
            2
        ) as payroll_wage_expense,
        round(sum(case when beds.account_name ilike '%overtime%' then beds.amount else 0 end), 2)
            as payroll_overtime_expense,
        round(sum(case when beds.account_number in ('6014', '6031') then beds.amount else 0 end), 2)
            as outside_hauling_expense,
        round(sum(beds.amount), 2) as net_income
    from {{ ref('stg_analytics_public__branch_earnings_dds_snap') }} as beds
        inner join {{ ref('market') }} as m
            on beds.market_id = m.child_market_id::text
    where beds.type != 'Intercompany Transactions'
    -- This is a catch all so we don't pull in adjustments that are made to dds early
        and date_trunc(month, beds.gl_date) <= '{{ last_branch_earnings_published_date() }}'
    group by all

    union all

    select * exclude (pk_id) from {{ ref('int_high_level_financials_trending') }}
),

rateachievement_points_cte as (
    select
        date_trunc(month, rp.invoice_date_created) as gl_date,
        m.market_id,
        round(sum(rp.percent_discount * rp.online_rate), 2) as average_discount_numerator,
        round(sum(rp.online_rate), 2) as average_discount_denominator
    from {{ ref("stg_analytics_public__rateachievement_points") }} as rp
        inner join {{ ref('market') }} as m
            on rp.market_id = m.child_market_id
    group by all
),

unassigned_hours as (
    select
        uth.gl_month as gl_date,
        m.market_id,
        round(sum(uth.unassigned_hours) / nullifzero(sum(uth.total_hours)), 4)
            as unassigned_hours_pct
    from {{ ref('unassigned_tech_hours') }} as uth
        inner join {{ ref('market') }} as m
            on uth.market_id = m.child_market_id
    group by all
),

cdv_dedup as (
    select
        employee_id,
        _es_update_timestamp,
        default_cost_centers_full_path
    from {{ ref('stg_analytics_payroll__company_directory_vault') }}
    qualify row_number() over (
            partition by employee_id, date_trunc(day, _es_update_timestamp)
            order by _es_update_timestamp desc
        ) = 1
),

non_es_wages as (
    select
        m.market_id,
        date_trunc(month, te.start_date) as gl_month,
        sum(te.regular_hours) * 64.4 as reg_wages, -- Hourly Wage
        sum(te.overtime_hours) * 96.6 as ot_wages   -- 1.5x Hourly Wage
    from period_date_series as pds
        -- identify who owned the asset when the work was done
        inner join {{ ref('stg_es_warehouse_time_tracking__time_entries') }} as te
            on pds.period_start_date = date_trunc(month, te.start_date)
        left join {{ ref('int_asset_historical_ownership') }} as ho
            on te.asset_id = ho.asset_id
                and date_trunc(day, te.start_date) = date_trunc(day, ho.daily_timestamp)
        left join {{ ref('stg_analytics_public__es_companies') }} as ec
            on ho.asset_company_id = ec.company_id
        left join {{ ref('stg_es_warehouse_public__users') }} as u -- to get employee id to join to cdv
            on te.user_id = u.user_id
        left join cdv_dedup as cdv  -- one row per employee per day
            on to_varchar(u.employee_id) = to_varchar(cdv.employee_id)
                and date_trunc(day, te.start_date) = date_trunc(day, cdv._es_update_timestamp)
        inner join {{ ref('market') }} as m
            on te.branch_id = m.child_market_id
    where te.branch_id is not null
        and cdv.default_cost_centers_full_path not like '%Tele%' -- remove telematics
        and te.approval_status = 'Approved'
        and ec.company_id is null -- identify non es-owned assets
        and ho.rental_branch_id is null -- these assets should not have an RSP
        and te.asset_id is not null -- only grab time entries towards an asset
        and te.work_order_id is not null
    group by all
),

out as (
    select
        md5(
            concat(
                coalesce(ec.market_id, oec.market_id)::text,
                '-',
                coalesce(ec.gl_date, oec.gl_date)::text
            )
        ) as pk_high_level_financials_id,
        coalesce(ec.gl_date, oec.gl_date) as gl_date,
        m.market_id,
        m.market_name,
        m.region_district as district,
        m.region_name,
        m.general_manager_employee_id,
        m.general_manager_name,
        m.general_manager_url_greenhouse,
        m.general_manager_url_disc,
        m.general_manager_disc_code,
        m.general_manager_email,
        m.general_manager_position_effective_date,
        round(coalesce(oec.oec, 0), 2) as oec,
        round(coalesce(oec.on_rent_oec, 0), 2) as on_rent_oec,
        round(coalesce(oec.unavailable_oec, 0), 2) as unavailable_oec,
        round(coalesce(ec.rental_revenue, 0), 2) as rental_revenue,
        round(coalesce(ec.delivery_revenue, 0), 2) as delivery_revenue,
        round(coalesce(ec.nonintercompany_delivery_revenue, 0), 2) as nonintercompany_delivery_revenue,
        -round(coalesce(ec.delivery_expense, 0), 2) as delivery_expense,
        round(coalesce(ec.sales_revenue, 0), 2) as sales_revenue,
        -round(coalesce(ec.sales_expense, 0), 2) as sales_expense,
        round(coalesce(ec.sales_revenue, 0) + coalesce(ec.sales_expense, 0), 2) as sales_gross_profit,
        round(coalesce(ec.total_revenue, 0), 2) as total_revenue,
        -round(coalesce(ec.payroll_compensation_expense, 0), 2) as payroll_compensation_expense,
        -round(coalesce(ec.payroll_wage_expense, 0), 2) as payroll_wage_expense,
        -round(coalesce(ec.payroll_overtime_expense, 0), 2) as payroll_overtime_expense,
        -round(coalesce(ec.outside_hauling_expense, 0), 2) as outside_hauling_expense,
        round(coalesce(ec.net_income, 0), 2) as net_income,
        round(rpc.average_discount_numerator, 2) as average_discount_numerator,
        round(rpc.average_discount_denominator, 2) as average_discount_denominator,
        round(coalesce(su.service_total_oec, 0), 2) as service_total_oec,
        round(coalesce(su.service_unavailable_oec, 0), 2) as service_unavailable_oec,
        round(coalesce(su.rental_fleet_oec_daily_sum, 0), 2) as rental_fleet_oec_daily_sum,
        round(coalesce(su.unavailable_oec_daily_sum, 0), 2) as unavailable_oec_daily_sum,
        round(coalesce(su.oec_on_rent_daily_sum, 0), 2) as oec_on_rent_daily_sum,
        round(uh.unassigned_hours_pct, 4) as unassigned_hours_pct,
        round(coalesce(new.reg_wages, 0), 2) as non_es_reg_wages,
        round(coalesce(new.ot_wages, 0), 2) as non_es_ot_wages,
        case
            when
                datediff('month', m.market_start_month, ec.gl_date) + 1 > 12
                then rank() over (partition by ec.gl_date order by coalesce(ec.net_income, 0) desc)
        end as month_rank
    from earnings_cte as ec
        full outer join oec_cte as oec
            on ec.market_id = oec.market_id
                and ec.gl_date = oec.gl_date
        inner join {{ ref('market') }} as m
            on coalesce(ec.market_id, oec.market_id) = m.child_market_id
        left join service_unavailable as su
            on m.market_id = su.market_id
                and coalesce(ec.gl_date, oec.gl_date) = su.gl_date
        left join rateachievement_points_cte as rpc
            on m.market_id = rpc.market_id
                and coalesce(ec.gl_date, oec.gl_date) = rpc.gl_date
        left join unassigned_hours as uh
            on m.market_id = uh.market_id
                and coalesce(ec.gl_date, oec.gl_date) = uh.gl_date
        left join non_es_wages as new
            on m.market_id = new.market_id
                and coalesce(ec.gl_date, oec.gl_date) = new.gl_month
)

select * from out

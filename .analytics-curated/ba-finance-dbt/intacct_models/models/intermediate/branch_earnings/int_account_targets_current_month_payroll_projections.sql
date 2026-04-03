with live_be_timestamp as (
-- Calculate percentage of the month completed for live branch earnings
    select distinct
        max(date_trunc(month, timestamp::date)) as be_live_max_month,
        max(date_part(day, timestamp::date)) / max(date_part(day, last_day(timestamp::date))) as month_completed_pct
    from {{ ref('int_live_branch_earnings_looker') }}
),

live_be_payroll_check as (
-- For unpublished but completed trending months, check if entirety of entries are from actuals
    select
        m.market_id,
        date_trunc(month, be.gl_date) as gl_month,
        be.account_number as account_no,
        coalesce(pbm.sage_name, be.account_name) as account_name,
        sum(case when be.source_model = 'int_live_branch_earnings_payroll_actuals' then abs(be.amount) else 0 end)
            / nullifzero(sum(abs(be.amount))) as pct_actuals
    from {{ ref('int_live_branch_earnings_looker') }} as be
        inner join {{ ref('stg_analytics_gs__plexi_bucket_mapping') }} as pbm
            on be.account_number = pbm.sage_gl
        inner join {{ ref('market') }} as m
            on be.market_id = m.child_market_id
    where coalesce(pbm.sage_name, be.account_name) ilike '%payroll%'
        and be.description not ilike '%dealership%sales%' -- Exclude Dealership Sales Offsets in Maintenance Payroll (for PDI)
    group by all
    having pct_actuals = 1
),

historicals as (
-- Pull historical monthly actuals by account for current month projections, pulling only from static
    select
        m.market_id,
        date_trunc(month, be.gl_date) as gl_month,
        coalesce(pbm.display_name, be.type) as account_category,
        be.account_number as account_no,
        coalesce(pbm.sage_name, be.account_name) as account_name,
        sum(case when (date_part(day, be.gl_date) / date_part(day, last_day(be.gl_date))) <= (select month_completed_pct from live_be_timestamp)
                then be.amount else 0 end) as mtd_amount,
        sum(be.amount) as monthly_amount
    from {{ ref('stg_analytics_public__branch_earnings_dds_snap') }} as be
        inner join {{ ref('market') }} m
            on be.market_id = m.child_market_id
        inner join {{ ref('stg_analytics_gs__plexi_bucket_mapping') }} as pbm
            on be.account_number = pbm.sage_gl
        inner join {{ ref('stg_analytics_gs__plexi_periods') }} as pp
            on date_trunc(month, be.gl_date) = pp.trunc::date
    where pp.period_published = 'published'
        and date_trunc(month, be.gl_date) >= dateadd(month, -3, (select be_live_max_month from live_be_timestamp))
        and coalesce(pbm.sage_name, be.account_name) ilike '%payroll%'
        and be.description not ilike '%dealership%sales%' -- Exclude Dealership Sales Offsets in Maintenance Payroll (for PDI)
        -- Exclude profit sharing accruals, but include reversals since these net out the profit sharing payout rolled up into the wage entries
        and (be.description not ilike '%profit%shar%' or be.description ilike '%reversal%profit%shar%')
    group by all

    union all

    select
        m.market_id,
        date_trunc(month, be.gl_date) as gl_month,
        coalesce(pbm.display_name, be.account_category) as account_category,
        be.account_number as account_no,
        coalesce(pbm.sage_name, be.account_name) as account_name,
        sum(case when (date_part(day, be.gl_date) / date_part(day, last_day(be.gl_date))) <= (select month_completed_pct from live_be_timestamp)
                then be.amount else 0 end) as mtd_amount,
        sum(be.amount) as monthly_amount
    from {{ ref('int_live_branch_earnings_looker') }} as be
        inner join {{ ref('market') }} m
            on be.market_id = m.child_market_id
        inner join {{ ref('stg_analytics_gs__plexi_bucket_mapping') }} as pbm
            on be.account_number = pbm.sage_gl
        inner join {{ ref('stg_analytics_gs__plexi_periods') }} as pp
            on date_trunc(month, be.gl_date) = pp.trunc::date
        inner join live_be_payroll_check as pc -- Only pull from trending if actuals are posted for the market/account/month
            on be.market_id = pc.market_id
                and date_trunc(month, be.gl_date) = pc.gl_month
                and be.account_number = pc.account_no
                and coalesce(pbm.sage_name, be.account_name) = pc.account_name
    where pp.period_published = 'published'
        and date_trunc(month, be.gl_date) >= dateadd(month, -3, (select be_live_max_month from live_be_timestamp))
        and coalesce(pbm.sage_name, be.account_name) ilike '%payroll%'
        and be.description not ilike '%dealership%sales%' -- Exclude Dealership Sales Offsets in Maintenance Payroll (for PDI)
        -- Exclude profit sharing accruals, but include reversals since these net out the profit sharing payout rolled up into the wage entries
        and (be.description not ilike '%profit%shar%' or be.description ilike '%reversal%profit%shar%')
    group by all
),

headcount as (
-- Get headcount by market/department/month
    select
        m.market_id,
        date_trunc(month, dd.date) as gl_month,
        sum(case when split_part(cd.default_cost_centers_full_path, '/', -1) in ('Equipment Rental', 'Sales') and cd.employee_title not ilike '%retail%' then 1 else 0 end) / max(date_part(day, last_day(dd.date))) as rental_headcount,
        sum(case when split_part(cd.default_cost_centers_full_path, '/', -1) = 'Maintenance' then 1 else 0 end) / max(date_part(day, last_day(dd.date))) as maint_headcount,
        sum(case when split_part(cd.default_cost_centers_full_path, '/', -1) = 'Delivery and Pickup' then 1 else 0 end) / max(date_part(day, last_day(dd.date))) as delivery_headcount,
        sum(case when split_part(cd.default_cost_centers_full_path, '/', -1) = 'Administrative' then 1 else 0 end) / max(date_part(day, last_day(dd.date))) as admin_headcount
    from {{ ref('dim_date') }} as dd
        inner join {{ ref('stg_analytics_payroll__company_directory') }} as cd
            on dd.date between cd.date_hired
                and coalesce(cd.date_terminated, '2099-12-31')
        inner join {{ ref('market') }} as m
            on cd.market_id = m.child_market_id
    where date_trunc(month,dd.date) between dateadd(month, -3, (select be_live_max_month from live_be_timestamp)) and (select be_live_max_month from live_be_timestamp)
    group by all
),

ot_hours as (
-- Get OT hours by market/department/month
    select
        m.market_type,
        m.market_id,
        m.district,
        datediff(month, m.branch_earnings_start_month, date_trunc(month, tt.end_date)) + 1 as months_open_at_time,
        date_trunc(month, tt.end_date) as gl_month,
        sum(case when split_part(cd.default_cost_centers_full_path, '/', -1) in ('Equipment Rental', 'Sales') and cd.employee_title not ilike '%retail%' then tt.overtime_hours else 0 end)  as rental_ot_hours,
        sum(case when split_part(cd.default_cost_centers_full_path, '/', -1) in ('Equipment Rental', 'Sales') and cd.employee_title not ilike '%retail%'
            and (date_part(day, tt.end_date) / date_part(day, last_day(tt.end_date))) <= (select month_completed_pct from live_be_timestamp) then tt.overtime_hours else 0 end)  as rental_ot_hours_mtd,
        sum(case when split_part(cd.default_cost_centers_full_path, '/', -1) = 'Maintenance' then tt.overtime_hours else 0 end) as maint_ot_hours,
        sum(case when split_part(cd.default_cost_centers_full_path, '/', -1) = 'Maintenance'
            and (date_part(day, tt.end_date) / date_part(day, last_day(tt.end_date))) <= (select month_completed_pct from live_be_timestamp) then tt.overtime_hours else 0 end)  as maint_ot_hours_mtd,
        sum(case when split_part(cd.default_cost_centers_full_path, '/', -1) = 'Delivery and Pickup' then tt.overtime_hours else 0 end) as delivery_ot_hours,
        sum(case when split_part(cd.default_cost_centers_full_path, '/', -1) = 'Delivery and Pickup'
            and (date_part(day, tt.end_date) / date_part(day, last_day(tt.end_date))) <= (select month_completed_pct from live_be_timestamp) then tt.overtime_hours else 0 end)  as delivery_ot_hours_mtd,
        sum(case when split_part(cd.default_cost_centers_full_path, '/', -1) = 'Administrative' then tt.overtime_hours else 0 end) as admin_ot_hours,
        sum(case when split_part(cd.default_cost_centers_full_path, '/', -1) = 'Administrative'
            and (date_part(day, tt.end_date) / date_part(day, last_day(tt.end_date))) <= (select month_completed_pct from live_be_timestamp) then tt.overtime_hours else 0 end)  as admin_ot_hours_mtd
    from {{ ref('stg_es_warehouse_time_tracking__time_entries') }} as tt
        inner join {{ ref('stg_es_warehouse_public__users') }} as u
            on tt.user_id = u.user_id
        inner join {{ ref('stg_analytics_payroll__company_directory') }} as cd
            on u.employee_id = cd.employee_id::text
        inner join {{ ref('market') }} as m
            on cd.market_id = m.child_market_id
    where date_trunc(month, tt.end_date) >= dateadd(month, -25, (select be_live_max_month from live_be_timestamp))
        and tt.approval_status = 'Approved'
        and tt.overtime_hours != 0
    group by all
),

ot_hours_w_monthly_lag as (
-- Add monthly lag columns to historical OT hours for seasonality calcs
    select
        oth.*,
        lag(oth.rental_ot_hours, 1) over (partition by oth.market_type, oth.market_id, oth.district order by oth.gl_month) as prior_month_rental_ot_hours,
        lag(oth.maint_ot_hours, 1) over (partition by oth.market_type, oth.market_id, oth.district order by oth.gl_month) as prior_month_maint_ot_hours,
        lag(oth.delivery_ot_hours, 1) over (partition by oth.market_type, oth.market_id, oth.district order by oth.gl_month) as prior_month_delivery_ot_hours,
        lag(oth.admin_ot_hours, 1) over (partition by oth.market_type, oth.market_id, oth.district order by oth.gl_month) as prior_month_admin_ot_hours
    from ot_hours as oth
),

ot_hours_seasonal_factor as (
-- For current month, calculate district-level MoM change by department to try and isolate seasonal MoM impact
    select
        market_type,
        district,
        sum(coalesce(rental_ot_hours,0) - coalesce(prior_month_rental_ot_hours,0)) / nullifzero(sum(coalesce(prior_month_rental_ot_hours,0))) as rental_ot_mom_pct_change,
        sum(coalesce(maint_ot_hours,0) - coalesce(prior_month_maint_ot_hours,0)) / nullifzero(sum(coalesce(prior_month_maint_ot_hours,0))) as maint_ot_mom_pct_change,
        sum(coalesce(delivery_ot_hours,0) - coalesce(prior_month_delivery_ot_hours,0)) / nullifzero(sum(coalesce(prior_month_delivery_ot_hours,0))) as delivery_ot_mom_pct_change,
        sum(coalesce(admin_ot_hours,0) - coalesce(prior_month_admin_ot_hours,0)) / nullifzero(sum(coalesce(prior_month_admin_ot_hours,0))) as admin_ot_mom_pct_change
    from ot_hours_w_monthly_lag
    where date_part(month, gl_month) = date_part(month, (select be_live_max_month from live_be_timestamp))
        and months_open_at_time > 12 -- only use mature markets
    group by market_type, district
),

ot_hours_seasonal_factor_capped as (
-- Cap seasonal factors to +/- 30% to avoid extreme outliers
    select
        market_type,
        district,
        (case
            when rental_ot_mom_pct_change > 0.3 then 0.3
            when rental_ot_mom_pct_change < -0.3 then -0.3
            else rental_ot_mom_pct_change
        end) as rental_ot_mom_pct_change,
        (case
            when maint_ot_mom_pct_change > 0.3 then 0.3
            when maint_ot_mom_pct_change < -0.3 then -0.3
            else maint_ot_mom_pct_change
        end) as maint_ot_mom_pct_change,
        (case
            when delivery_ot_mom_pct_change > 0.3 then 0.3
            when delivery_ot_mom_pct_change < -0.3 then -0.3
            else delivery_ot_mom_pct_change
        end) as delivery_ot_mom_pct_change,
        (case
            when admin_ot_mom_pct_change > 0.3 then 0.3
            when admin_ot_mom_pct_change < -0.3 then -0.3
            else admin_ot_mom_pct_change
        end) as admin_ot_mom_pct_change
 from ot_hours_seasonal_factor
),

last_3_month_actuals as (
-- Combine historicals with headcount and OT hours
    select
        h.*,
        (case
            when h.account_name ilike '%national%sales%' then 1 -- For Retail Sales Payroll, don't use branch level headcount, just use 1 to pull through monthly avg
            when h.account_name ilike '%rental%' then hc.rental_headcount
            when h.account_name ilike '%maint%' then hc.maint_headcount
            when h.account_name ilike '%delivery%' then hc.delivery_headcount
            when h.account_name ilike '%admin%' then hc.admin_headcount
            else 0
        end) as dept_headcount,
        (case
            when h.account_name ilike '%rental%' then ot.rental_ot_hours
            when h.account_name ilike '%maint%' then ot.maint_ot_hours
            when h.account_name ilike '%delivery%' then ot.delivery_ot_hours
            when h.account_name ilike '%admin%' then ot.admin_ot_hours
            else 0
        end) as dept_ot_hours,
        date_part(day, last_day(h.gl_month)) as month_days
    from historicals as h
        left join headcount as hc
            on h.market_id = hc.market_id
                and h.gl_month = hc.gl_month
        left join ot_hours as ot
            on h.market_id = ot.market_id
                and h.gl_month = ot.gl_month
),

last_3_month_avgs as (
-- Calculate cost per head/day and cost per OT hour by account based on last 3 months actuals
    select
        market_id,
        account_no,
        account_name,
        sum(case when account_name not ilike '%overtime%' then monthly_amount else 0 end)
        / nullifzero(sum(case when account_name not ilike '%overtime%' then dept_headcount * month_days else 0 end)) as cost_per_head_day,
        sum(case when account_name ilike '%overtime%' then monthly_amount else 0 end)
        / nullifzero(sum(case when account_name ilike '%overtime%' then dept_ot_hours else 0 end)) as cost_per_ot_hour,
        avg(dept_ot_hours) as avg_ot_hours
    from last_3_month_actuals
    group by market_id, account_no, account_name
),

historical_ot_mtd as (
-- Get TTM Avg MTD OT Hours % by account/market type
    select
        market_type,
        sum(rental_ot_hours_mtd) / nullifzero(sum(rental_ot_hours)) as rental_ot_mtd_pct,
        sum(maint_ot_hours_mtd) / nullifzero(sum(maint_ot_hours)) as maint_ot_mtd_pct,
        sum(delivery_ot_hours_mtd) / nullifzero(sum(delivery_ot_hours)) as delivery_ot_mtd_pct,
        sum(admin_ot_hours_mtd) / nullifzero(sum(admin_ot_hours)) as admin_ot_mtd_pct
    from ot_hours
    where gl_month >= dateadd(month, -12, (select be_live_max_month from live_be_timestamp))
    group by market_type
)

select
    mm.market_id,
    mm.gl_month,
    mm.account_no,
    mm.account_name,
    mm.rev_exp,
    mm.account_category,
    mm.cost_type,
    mm.actual_amount,
    mm.comp_metric,
    mm.comp_metric_amount,
    (case
        when mm.account_name ilike '%national%sales%' then 1 -- For Retail Sales Payroll, don't use branch level headcount, just use 1 to pull through monthly avg
        when mm.account_name ilike '%rental%' then hc.rental_headcount
        when mm.account_name ilike '%maintenance%' then hc.maint_headcount
        when mm.account_name ilike '%delivery%' then hc.delivery_headcount
        when mm.account_name ilike '%administrative%' then hc.admin_headcount
    end) as headcount,
    l3ma.cost_per_head_day,
    l3ma.cost_per_ot_hour,
    l3ma.avg_ot_hours,
    (case
        when mm.account_name ilike '%rental%' then ots.rental_ot_mom_pct_change
        when mm.account_name ilike '%maintenance%' then ots.maint_ot_mom_pct_change
        when mm.account_name ilike '%delivery%' then ots.delivery_ot_mom_pct_change
        when mm.account_name ilike '%administrative%' then ots.admin_ot_mom_pct_change
    end) as ot_mom_pct_change,
    (case
        when mm.account_name ilike '%rental%' then ot.rental_ot_hours
        when mm.account_name ilike '%maintenance%' then ot.maint_ot_hours
        when mm.account_name ilike '%delivery%' then ot.delivery_ot_hours
        when mm.account_name ilike '%administrative%' then ot.admin_ot_hours
    end) as ot_hours,
    (case
        when mm.gl_month < date_trunc(month, (select be_live_max_month from live_be_timestamp)) then 1
        when mm.account_name ilike '%rental%' then hot.rental_ot_mtd_pct
        when mm.account_name ilike '%maintenance%' then hot.maint_ot_mtd_pct
        when mm.account_name ilike '%delivery%' then hot.delivery_ot_mtd_pct
        when mm.account_name ilike '%administrative%' then hot.admin_ot_mtd_pct
    end) as hist_ot_mtd_pct,
    (case
        when mm.gl_month < date_trunc(month, (select be_live_max_month from live_be_timestamp)) then 1
        else (select month_completed_pct from live_be_timestamp)
    end) as current_month_completed_pct,
    (case
        -- For unpublished completed months that have accounting actuals for payroll, just use the actuals
        when current_month_completed_pct = 1 and pc.pct_actuals = 1 then mm.actual_amount
        -- For non-OT accounts, multiply days in month * headcount * cost per head/day
        when mm.account_name not ilike '%overtime%'
            then date_part(day, last_day(mm.gl_month)) * headcount * l3ma.cost_per_head_day
        -- For OT accounts, estimate current month OT hours by blending seasonal adjusted trailing 3 month avg
        -- with historical MTD %, weighted by % of month completed
        when mm.account_name ilike '%overtime%'
            then l3ma.cost_per_ot_hour * ((coalesce(l3ma.avg_ot_hours, 0) * (1 + coalesce(ot_mom_pct_change, 0)) * (1 - current_month_completed_pct))
                    + (coalesce(ot_hours / nullifzero(hist_ot_mtd_pct), 0) * current_month_completed_pct))
    end) as month_end_projected_amount
from {{ ref('int_account_targets_actuals_live') }} as mm
    inner join {{ ref('market') }} as m
        on mm.market_id = m.child_market_id
    left join headcount as hc
        on mm.market_id = hc.market_id
            and mm.gl_month = hc.gl_month
    left join ot_hours as ot
        on mm.market_id = ot.market_id
            and mm.gl_month = ot.gl_month
    left join ot_hours_seasonal_factor_capped as ots
        on m.market_type = ots.market_type
            and m.district = ots.district
    left join historical_ot_mtd as hot
        on m.market_type = hot.market_type
    left join last_3_month_avgs as l3ma
        on mm.market_id = l3ma.market_id
            and mm.account_no = l3ma.account_no
    left join live_be_payroll_check as pc
        on mm.market_id = pc.market_id
            and mm.gl_month = pc.gl_month
            and mm.account_no = pc.account_no
            and mm.account_name = pc.account_name
where mm.account_name ilike '%payroll%'
    and mm.account_name not ilike '%payroll%tax%expense%'

with live_be_timestamp as (
-- Calculate percentage of the month completed for live branch earnings
    select distinct
        max(date_trunc(month, timestamp::date)) as be_live_max_month,
        max(date_part(day, timestamp::date)) / max(date_part(day, last_day(timestamp::date))) as month_completed_pct
    from {{ ref('int_live_branch_earnings_looker') }}
),

historical_account_actuals_base as (
-- Union actuals from static and live BE
    select *
    from {{ ref('int_account_targets_actuals_static') }}
    union all
    select *
    from {{ ref('int_account_targets_actuals_live') }}
),

historical_account_actuals as (
-- Apply override_flag: projection method per account (2=use live BE outright, 1=T3M avg w/ seasonal adj, 0=weighted blend).
-- Also add market type and district, and restrict to historical completed months from past 2 years
    select
        m.market_type,
        m.market_id,
        m.district,
        base.gl_month,
        datediff(month, m.branch_earnings_start_month, base.gl_month) + 1 as months_open_at_time,
        base.account_category,
        base.account_no,
        (case
            when base.account_no in ('HGAD', 'HIAB', 'HIAC', 'IBAB', 'JAAA', 'HFAB', 'HFAH', 'HFAI') then 2
            when base.account_name ilike '%payroll%' then 1
            when base.account_name ilike '%commission%' then 1
            when base.account_name ilike '%depreciation%' then 1
            when base.account_category = 'Employee Benefits Expenses' then 1
            when base.account_category = 'Facilities Expenses' and base.account_no not in ('7604', '7608', '7609', '7610', '7614', '7806') then 1
            when base.account_category = 'General Expenses' and base.account_no not in ('6320', '7104', '7105', '7402', '7406', '7407', '7409') then 1
            when base.account_category = 'Cost of Miscellaneous Revenues' and base.account_no not in ('5201', '6007', '6301', '7008') then 1
            when base.account_category = 'Overhead Expenses' and base.account_no not in ('7000', '7001', '7106', '7300', '7301', '7302', '7304', '7405', '7500', '7800') then 1
            when base.account_no in ('5019', '5450', '5451', '6015', '6050', '6051', '6303', '6304', '6307', '6308', 'IAAA') then 1
            else 0
        end) as override_flag,
        sum(base.mtd_amount) as mtd_amount,
        sum(base.actual_amount) as monthly_amount
    from historical_account_actuals_base as base
        inner join {{ ref('market') }} as m on base.market_id = m.child_market_id
    where base.gl_month >= dateadd(month, -25, (select be_live_max_month from live_be_timestamp))
        and base.gl_month < (select be_live_max_month from live_be_timestamp)
    group by all
),

historicals_w_monthly_lag as (
-- Add monthly lag columns to historicals for seasonality calcs
    select
        ha.*,
        lag(ha.monthly_amount, 1) over (partition by ha.market_type, ha.market_id, ha.district, ha.account_category, ha.account_no order by ha.gl_month) as prior_month_amount
    from historical_account_actuals as ha
),

account_seasonal_factor as (
-- For current month, calculate district-level MoM change by account to try and isolate seasonal MoM impact
    select
        market_type,
        district,
        account_no,
        sum(coalesce(monthly_amount, 0) - coalesce(prior_month_amount, 0)) / nullifzero(sum(coalesce(prior_month_amount, 0))) as avg_mom_pct_change
    from historicals_w_monthly_lag
    where date_part(month, gl_month) = date_part(month, (select be_live_max_month from live_be_timestamp))
        and months_open_at_time > 12 -- only use mature markets
    group by market_type, district, account_no
),

account_seasonal_factor_capped as (
-- Cap seasonal factors to +/- 30% to avoid extreme outliers
    select
        asf.market_type,
        asf.district,
        asf.account_no,
        (case
            when asf.avg_mom_pct_change > 0.3 then 0.3
            when asf.avg_mom_pct_change < -0.3 then -0.3
            else asf.avg_mom_pct_change
        end) as avg_mom_pct_change
    from account_seasonal_factor as asf
),

revenue_metrics_seasonal_factors as (
-- For current month, calcualte district-level MoM change for aggregated revenue comp metrics
    select
        market_type,
        district,
        sum(case when account_category in ('Rental Revenues', 'Service Revenues', 'Retail Revenues', 'Miscellaneous Revenues')
                then coalesce(monthly_amount, 0) - coalesce(prior_month_amount, 0) else 0 end)
        / nullifzero(sum(case when account_category in ('Rental Revenues', 'Service Revenues', 'Retail Revenues', 'Miscellaneous Revenues')
                then coalesce(prior_month_amount, 0) else 0 end)) as total_rev_mom_pct_change,
        sum(case when account_category in ('Rental Revenues')
                then coalesce(monthly_amount, 0) - coalesce(prior_month_amount, 0) else 0 end)
        / nullifzero(sum(case when account_category in ('Rental Revenues')
                then coalesce(prior_month_amount, 0) else 0 end)) as rental_rev_mom_pct_change,
        sum(case when account_category in ('Rental Revenues', 'Service Revenues')
                then coalesce(monthly_amount, 0) - coalesce(prior_month_amount, 0) else 0 end)
        / nullifzero(sum(case when account_category in ('Rental Revenues', 'Service Revenues')
                then coalesce(prior_month_amount, 0) else 0 end)) as rental_service_rev_mom_pct_change,
        sum(case when account_category in ('Retail Revenues')
                then coalesce(monthly_amount, 0) - coalesce(prior_month_amount, 0) else 0 end)
        / nullifzero(sum(case when account_category in ('Retail Revenues')
                then coalesce(prior_month_amount, 0) else 0 end)) as retail_rev_mom_pct_change
    from historicals_w_monthly_lag
    where date_part(month, gl_month) = date_part(month, (select be_live_max_month from live_be_timestamp))
        and months_open_at_time > 12 -- only use mature markets
    group by market_type, district
),

revenue_metrics_seasonal_factors_capped as (
-- Cap seasonal factors to +/- 30% to avoid extreme outliers
    select
        rmsf.market_type,
        rmsf.district,
        (case
            when rmsf.total_rev_mom_pct_change > 0.3 then 0.3
            when rmsf.total_rev_mom_pct_change < -0.3 then -0.3
            else rmsf.total_rev_mom_pct_change
        end) as total_rev_mom_pct_change,
        (case
            when rmsf.rental_rev_mom_pct_change > 0.3 then 0.3
            when rmsf.rental_rev_mom_pct_change < -0.3 then -0.3
            else rmsf.rental_rev_mom_pct_change
        end) as rental_rev_mom_pct_change,
        (case
            when rmsf.rental_service_rev_mom_pct_change > 0.3 then 0.3
            when rmsf.rental_service_rev_mom_pct_change < -0.3 then -0.3
            else rmsf.rental_service_rev_mom_pct_change
        end) as rental_service_rev_mom_pct_change,
        (case
            when rmsf.retail_rev_mom_pct_change > 0.3 then 0.3
            when rmsf.retail_rev_mom_pct_change < -0.3 then -0.3
            else rmsf.retail_rev_mom_pct_change
        end) as retail_rev_mom_pct_change
    from revenue_metrics_seasonal_factors as rmsf
),

actuals_last_3_month_avg as (
-- Get trailing 3 months avg by market/account, will use this along with seasonal factor to project current month
    select
        market_id,
        account_no,
        max(override_flag) as override_flag,
        sum(monthly_amount) / nullifzero(count(distinct gl_month)) as trailing_3_month_avg
    from historical_account_actuals
    where gl_month >= dateadd(month, -3, (select be_live_max_month from live_be_timestamp))
    group by market_id, account_no
),

revenue_metrics_last_3_month_avg as (
-- Get trailing 3 months avg by market/aggregated rev metric, will use this along with seasonal factor to project current month
    select
        market_id,
        sum(case when account_category in ('Rental Revenues', 'Service Revenues', 'Retail Revenues', 'Miscellaneous Revenues') 
                then monthly_amount else 0 end)
        / nullifzero(count(distinct case when account_category in ('Rental Revenues', 'Service Revenues', 'Retail Revenues', 'Miscellaneous Revenues')
                then gl_month end)) as total_rev_trailing_3_month_avg,
        sum(case when account_category in ('Rental Revenues')
                then monthly_amount else 0 end)
        / nullifzero(count(distinct case when account_category in ('Rental Revenues')
                then gl_month end)) as rental_rev_trailing_3_month_avg,
        sum(case when account_category in ('Rental Revenues', 'Service Revenues')
                then monthly_amount else 0 end)
        / nullifzero(count(distinct case when account_category in ('Rental Revenues', 'Service Revenues')
                then gl_month end)) as rental_service_rev_trailing_3_month_avg,
        sum(case when account_category in ('Retail Revenues')
                then monthly_amount else 0 end)
        / nullifzero(count(distinct case when account_category in ('Retail Revenues')
                then gl_month end)) as retail_rev_trailing_3_month_avg
    from historical_account_actuals
    where gl_month >= dateadd(month, -3, (select be_live_max_month from live_be_timestamp))
    group by market_id
),

historical_account_actuals_mtd as (
-- Get TTM Avg MTD % by account/market type
    select
        market_type,
        account_no,
        sum(mtd_amount) / nullifzero(sum(monthly_amount)) as pct_of_total
    from historical_account_actuals
    where gl_month >= dateadd(month, -12, (select be_live_max_month from live_be_timestamp))
    group by market_type, account_no
),

historical_revenue_metrics_actuals_mtd as (
-- Get TTM Avg MTD % by revenue comp metric/market_type
    select
        market_type,
        sum(case when account_category in ('Rental Revenues', 'Service Revenues', 'Retail Revenues', 'Miscellaneous Revenues')
                then mtd_amount else 0 end)
        / nullifzero(sum(case when account_category in ('Rental Revenues', 'Service Revenues', 'Retail Revenues', 'Miscellaneous Revenues')
                then monthly_amount else 0 end)) as total_rev_pct_total,
        sum(case when account_category in ('Rental Revenues')
                then mtd_amount else 0 end)
        / nullifzero(sum(case when account_category in ('Rental Revenues') 
                then monthly_amount else 0 end)) as rental_rev_pct_total,
        sum(case when account_category in ('Rental Revenues', 'Service Revenues')
                then mtd_amount else 0 end)
        / nullifzero(sum(case when account_category in ('Rental Revenues', 'Service Revenues')
                then monthly_amount else 0 end)) as rental_service_rev_pct_total,
        sum(case when account_category in ('Retail Revenues')
                then mtd_amount else 0 end)
        / nullifzero(sum(case when account_category in ('Retail Revenues')
                then monthly_amount else 0 end)) as retail_rev_pct_total
    from historical_account_actuals
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
    l3m.override_flag as account_override_flag,
    l3m.trailing_3_month_avg,
    asf.avg_mom_pct_change as seasonal_factor,
    ham.pct_of_total as hist_account_mtd_pct,
    (select month_completed_pct from live_be_timestamp) as current_month_completed_pct,
    (case
        when (mm.account_name ilike '%payroll%' and mm.account_name not ilike '%payroll%tax%expense%') then null -- Will estimate payroll accounts in separate model
        when mm.gl_month != (select be_live_max_month from live_be_timestamp) then mm.actual_amount -- for unpublished but completed months, use what is in trending
        when l3m.override_flag = 2 then mm.actual_amount -- for selected facilities expense accounts, use value in live BE outright
        when l3m.override_flag = 1 then coalesce(l3m.trailing_3_month_avg, 0) * (1 + coalesce(asf.avg_mom_pct_change, 0)) -- input trailing 3 month avg w/ seasonal adj for flagged accounts)
        else ((coalesce(l3m.trailing_3_month_avg, 0) * (1 + coalesce(asf.avg_mom_pct_change, 0))) * (1 - (select month_completed_pct from live_be_timestamp)))
            + (coalesce(mm.actual_amount / nullifzero(ham.pct_of_total), 0) * (select month_completed_pct from live_be_timestamp)) -- For all other accounts, blend seasonal adjusted trailing 3 month avg with historical MTD %, weighted by % of month completed
    end) as month_end_projected_amount,
    (case
        when mm.gl_month != (select be_live_max_month from live_be_timestamp) then mm.comp_metric_amount -- for unpublished but completed months, use what is in trending
        when mm.comp_metric = 'Annualized % of OEC' then mm.comp_metric_amount -- For OEC-based accounts, use MTD avg daily OEC as stand-in for month end amount
        when mm.comp_metric = '% of Rental Revenue' then ((coalesce(rml3.rental_rev_trailing_3_month_avg, 0) * (1 + coalesce(rmsf.rental_rev_mom_pct_change, 0))) * (1 - (select month_completed_pct from live_be_timestamp)))
                + (coalesce(mm.comp_metric_amount / nullifzero(hrmm.rental_rev_pct_total), 0) * (select month_completed_pct from live_be_timestamp))
        when mm.comp_metric = '% of Rental & Service Revenue' then ((coalesce(rml3.rental_service_rev_trailing_3_month_avg, 0) * (1 + coalesce(rmsf.rental_service_rev_mom_pct_change, 0))) * (1 - (select month_completed_pct from live_be_timestamp)))
                + (coalesce(mm.comp_metric_amount / nullifzero(hrmm.rental_service_rev_pct_total), 0) * (select month_completed_pct from live_be_timestamp))
        when mm.comp_metric = '% of Retail Revenue' then ((coalesce(rml3.retail_rev_trailing_3_month_avg, 0) * (1 + coalesce(rmsf.retail_rev_mom_pct_change, 0))) * (1 - (select month_completed_pct from live_be_timestamp)))
                + (coalesce(mm.comp_metric_amount / nullifzero(hrmm.retail_rev_pct_total), 0) * (select month_completed_pct from live_be_timestamp))
        when mm.comp_metric = '% of Total Revenue' then ((coalesce(rml3.total_rev_trailing_3_month_avg, 0) * (1 + coalesce(rmsf.total_rev_mom_pct_change, 0))) * (1 - (select month_completed_pct from live_be_timestamp)))
                + (coalesce(mm.comp_metric_amount / nullifzero(hrmm.total_rev_pct_total), 0) * (select month_completed_pct from live_be_timestamp))
        else ((coalesce(rml3.total_rev_trailing_3_month_avg, 0) * (1 + coalesce(rmsf.total_rev_mom_pct_change, 0))) * (1 - (select month_completed_pct from live_be_timestamp)))
            + (coalesce(mm.comp_metric_amount / nullifzero(hrmm.total_rev_pct_total), 0) * (select month_completed_pct from live_be_timestamp))
    end) as month_end_projected_comp_metric_amount
from {{ ref('int_account_targets_actuals_live') }} as mm
    inner join {{ ref('market') }} as m
        on mm.market_id = m.child_market_id
    left join actuals_last_3_month_avg as l3m
        on mm.market_id = l3m.market_id
            and mm.account_no = l3m.account_no
            and mm.gl_month = (select be_live_max_month from live_be_timestamp)
    left join account_seasonal_factor_capped as asf
        on m.market_type = asf.market_type
            and m.district = asf.district
            and mm.account_no = asf.account_no
            and mm.gl_month = (select be_live_max_month from live_be_timestamp)
    left join historical_account_actuals_mtd as ham
        on m.market_type = ham.market_type
            and mm.account_no = ham.account_no
            and mm.gl_month = (select be_live_max_month from live_be_timestamp)
    left join revenue_metrics_last_3_month_avg as rml3
        on mm.market_id = rml3.market_id
            and mm.gl_month = (select be_live_max_month from live_be_timestamp)
    left join revenue_metrics_seasonal_factors_capped as rmsf
        on m.market_type = rmsf.market_type
            and m.district = rmsf.district
            and mm.gl_month = (select be_live_max_month from live_be_timestamp)
    left join historical_revenue_metrics_actuals_mtd as hrmm
        on m.market_type = hrmm.market_type
            and mm.gl_month = (select be_live_max_month from live_be_timestamp)

with mtd_pct_completed as (
-- Calculate percentage of the month completed for live branch earnings
    select distinct
        max(date_part(day, timestamp::date)) / max(date_part(day, last_day(timestamp::date))) as month_completed_pct
    from {{ ref('int_live_branch_earnings_looker') }}
),

actuals_oec as (
-- Get Avg daily OEC per market per month
    select
        m.market_id,
        date_trunc(month, oec.daily_timestamp::date) as gl_month,
        sum(oec.total_oec) / nullifzero(count(distinct oec.daily_timestamp)) as oec,
        sum(oec.rental_fleet_oec) / nullifzero(count(distinct oec.daily_timestamp)) as rental_fleet_oec
    from {{ ref('market_level_asset_metrics_daily') }} as oec
        inner join {{ ref('market') }} as m
            on oec.market_id = m.child_market_id
        inner join {{ ref('stg_analytics_gs__plexi_periods') }} as pp
            on date_trunc(month, oec.daily_timestamp::date) = pp.trunc::date
    where pp.period_published is null
    group by m.market_id, date_trunc(month, oec.daily_timestamp::date)
),

actuals_monthly_revenues as (
-- Get Monthly Revenues
    select
        m.market_id,
        date_trunc(month, be.gl_date) as gl_month,
        sum(case when be.account_category in ('Rental Revenues', 'Service Revenues', 'Retail Revenues', 'Miscellaneous Revenues') then be.amount else 0 end) as total_rev,
        sum(case when be.account_category in ('Rental Revenues') then be.amount else 0 end) as rental_rev,
        sum(case when be.account_category in ('Rental Revenues', 'Service Revenues') then be.amount else 0 end) as rental_service_rev,
        sum(case when be.account_category in ('Retail Revenues') then be.amount else 0 end) as retail_rev
    from {{ ref('int_live_branch_earnings_looker') }} as be
        inner join {{ ref('market') }} as m
            on be.market_id = m.child_market_id
        inner join {{ ref('stg_analytics_gs__plexi_periods') }} as pp
            on date_trunc(month, be.gl_date) = pp.trunc::date
    where pp.period_published is null
    group by m.market_id, date_trunc(month, be.gl_date)
),

monthly_actuals as (
-- Get Monthly total amounts by account
    select
        m.market_id,
        date_trunc(month, be.gl_date) as gl_month,
        case
            when be.account_number in ('FABA', 'FAAA') then '5000'
            when be.account_number = 'FCDA' then 'FCBA'
            when be.account_number = 'GDCC' then 'GDCB'
            else be.account_number
        end as account_no,
        coalesce(pbm.sage_name, be.account_name) as account_name,
        coalesce(pbm.revexp, (case when be.revenue_expense = 'revenue' then 'REV' else 'EXP' end)) as rev_exp,
        coalesce(pbm.display_name, be.account_category) as account_category,
        cmm.cost_type,
        round(sum(coalesce(be.amount, 0)), 2) as actual_amount,
        sum(case when (date_part(day, be.gl_date) / date_part(day, last_day(be.gl_date))) <= (select month_completed_pct from mtd_pct_completed)
                then coalesce(be.amount, 0) else 0 end) as mtd_amount,
        cmm.comp_metric
    from {{ ref('int_live_branch_earnings_looker') }} as be
        inner join {{ ref('stg_analytics_gs__plexi_bucket_mapping') }} as pbm
            on
                case
                    when be.account_number in ('FABA', 'FAAA') then '5000'
                    when be.account_number = 'FCDA' then 'FCBA'
                    when be.account_number = 'GDCC' then 'GDCB'
                    else be.account_number
                end = pbm.sage_gl
        left join {{ ref('seed_account_targets_account_comp_metric_map') }} as cmm
            on
                case
                    when be.account_number in ('FABA', 'FAAA') then '5000'
                    when be.account_number = 'FCDA' then 'FCBA'
                    when be.account_number = 'GDCC' then 'GDCB'
                    else be.account_number
                end = cmm.account_no
        inner join {{ ref('market') }} as m
            on be.market_id = m.child_market_id
        inner join {{ ref('stg_analytics_gs__plexi_periods') }} as pp
            on date_trunc(month, be.gl_date) = pp.trunc::date
    where pp.period_published is null
    group by all
),

-- Current month trending may not have actuals for an account yet; create an account spine
-- and full outer join to monthly actuals so we have a row per market/month/account.
month_spine as (
    select distinct gl_month
    from monthly_actuals
),

market_spine as (
    select distinct market_id
    from monthly_actuals
),

account_spine as (
    select distinct
        account_no,
        account_name,
        rev_exp,
        account_category,
        cost_type,
        comp_metric
    from monthly_actuals
),

spine as (
    select
        ms.market_id,
        mo.gl_month,
        a.account_no,
        a.account_name,
        a.rev_exp,
        a.account_category,
        a.cost_type,
        a.comp_metric
    from market_spine as ms
        cross join month_spine as mo
        cross join account_spine as a
),

monthly_actuals_full as (
    select
        s.market_id,
        s.gl_month,
        s.account_no,
        s.account_name,
        s.rev_exp,
        s.account_category,
        s.cost_type,
        coalesce(ma.actual_amount, 0) as actual_amount,
        coalesce(ma.mtd_amount, 0) as mtd_amount,
        s.comp_metric
    from spine as s
        left join monthly_actuals as ma
            on s.market_id = ma.market_id
                and s.gl_month = ma.gl_month
                and s.account_no = ma.account_no
                --and s.cost_type = ma.cost_type
                --and s.comp_metric = ma.comp_metric
)

-- Map on Comp OEC/Rev metrics based on comp_metric flag 
select
    ma.*,
    (case
        when ma.comp_metric = 'Annualized % of OEC' then coalesce(oec.rental_fleet_oec, 0)
        when ma.comp_metric = '% of Rental Revenue' then coalesce(rev.rental_rev, 0)
        when ma.comp_metric = '% of Rental & Service Revenue' then coalesce(rev.rental_service_rev, 0)
        when ma.comp_metric = '% of Retail Revenue' then coalesce(rev.retail_rev, 0)
        when ma.comp_metric = '% of Total Revenue' then coalesce(rev.total_rev, 0)
        else coalesce(rev.total_rev, 0)
    end) as comp_metric_amount
from monthly_actuals_full as ma
    left join actuals_oec as oec
        on ma.market_id = oec.market_id
            and ma.gl_month = oec.gl_month
    left join actuals_monthly_revenues as rev
        on ma.market_id = rev.market_id
            and ma.gl_month = rev.gl_month

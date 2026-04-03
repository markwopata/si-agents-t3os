with max_published_month as (
    select max(trunc::date) as max_published_month
    from {{ ref('stg_analytics_gs__plexi_periods') }}
    where period_published = 'published'
),

mtd_pct_completed as (
-- Calculate percentage of the month completed, will use later for month-end projections
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
    where date_trunc(month, oec.daily_timestamp::date) between '2024-01-01' and (select max_published_month from max_published_month)
    group by m.market_id, date_trunc(month, oec.daily_timestamp::date)
),

actuals_monthly_revenues as (
-- Get Monthly Revenues
    select
        m.market_id,
        date_trunc(month, be.gl_date) as gl_month,
        sum(case when be.type in ('Rental Revenues', 'Service Revenues', 'Retail Revenues', 'Miscellaneous Revenues') then be.amount else 0 end) as total_rev,
        sum(case when be.type in ('Rental Revenues') then be.amount else 0 end) as rental_rev,
        sum(case when be.type in ('Rental Revenues', 'Service Revenues') then be.amount else 0 end) as rental_service_rev,
        sum(case when be.type in ('Retail Revenues') then be.amount else 0 end) as retail_rev
    from {{ ref('stg_analytics_public__branch_earnings_dds_snap') }} as be
        inner join {{ ref('market') }} as m 
            on be.market_id = m.child_market_id
    where date_trunc(month, be.gl_date) between '2024-01-01' and (select max_published_month from max_published_month)
    group by m.market_id, date_trunc(month, be.gl_date)
),

monthly_actuals as (
-- Get Monthly total amounts by account
    select
        m.market_id,
        date_trunc(month, be.gl_date) as gl_month,
        be.account_number as account_no,
        coalesce(pbm.sage_name, be.account_name) as account_name,
        coalesce(pbm.revexp, be.revenue_expense_category) as rev_exp,
        coalesce(pbm.display_name, be.type) as account_category,
        cmm.cost_type,
        round(sum(coalesce(be.amount, 0)), 2) as actual_amount,
        sum(case when (date_part(day, be.gl_date) / date_part(day, last_day(be.gl_date))) <= (select month_completed_pct from mtd_pct_completed)
                then coalesce(be.amount, 0) else 0 end) as mtd_amount,
        cmm.comp_metric
    from {{ ref('stg_analytics_public__branch_earnings_dds_snap') }} as be
        inner join {{ ref('stg_analytics_gs__plexi_bucket_mapping') }} as pbm
            on be.account_number = pbm.sage_gl
        left join {{ ref('seed_account_targets_account_comp_metric_map') }} as cmm
            on be.account_number = cmm.account_no
        inner join {{ ref('market') }} as m 
            on be.market_id = m.child_market_id
    where date_trunc(month, be.gl_date) between '2024-01-01' and (select max_published_month from max_published_month)
    group by all
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
from monthly_actuals as ma
    left join actuals_oec as oec
        on ma.market_id = oec.market_id
            and ma.gl_month = oec.gl_month
    left join actuals_monthly_revenues as rev
        on ma.market_id = rev.market_id
            and ma.gl_month = rev.gl_month

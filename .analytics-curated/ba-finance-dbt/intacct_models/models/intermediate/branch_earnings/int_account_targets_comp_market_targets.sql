with max_published_month as (
    select max(trunc::date) as max_published_month
    from {{ ref('stg_analytics_gs__plexi_periods') }}
    where period_published = 'published'
),

comp_date_param as (
    select
        dateadd(month, -11, (select max_published_month from max_published_month)) as start_date,
        (select max_published_month from max_published_month) as end_date
),

comp_market_monthly_oec as (
-- Get Avg daily OEC per market per month for comp markets
    select
        m.market_id,
        cm.comp_markets_id,
        date_trunc(month, oec.daily_timestamp::date) as gl_month,
        sum(oec.total_oec) / nullifzero(count(distinct oec.daily_timestamp)) as comp_oec,
        sum(oec.rental_fleet_oec) / nullifzero(count(distinct oec.daily_timestamp)) as comp_rental_fleet_oec
    from {{ ref('market_level_asset_metrics_daily') }} as oec
        inner join {{ ref('market') }} as m
            on oec.market_id = m.child_market_id
        inner join {{ ref('seed_account_targets_comp_markets') }} as cm
            on m.market_id = cm.market_id
    where date_trunc(month, oec.daily_timestamp::date) between (select start_date from comp_date_param) and (select end_date from comp_date_param)
    group by m.market_id, cm.comp_markets_id, date_trunc(month, oec.daily_timestamp::date)
),

comp_monthly_oec as (
-- Get Monthly OEC summed across all comp markets
    select
        comp_markets_id,
        gl_month,
        sum(comp_oec) as comp_oec,
        sum(comp_rental_fleet_oec) as comp_rental_fleet_oec
    from comp_market_monthly_oec
    group by comp_markets_id, gl_month
),

comp_monthly_revenues as (
-- Get Monthly Revenues summed across all comp markets
    select
        cm.comp_markets_id,
        date_trunc(month, be.gl_date) as gl_month,
        sum(case when be.type in ('Rental Revenues', 'Service Revenues', 'Retail Revenues', 'Miscellaneous Revenues') then be.amount else 0 end) as comp_total_rev,
        sum(case when be.type in ('Rental Revenues') then be.amount else 0 end) as comp_rental_rev,
        sum(case when be.type in ('Rental Revenues', 'Service Revenues') then be.amount else 0 end) as comp_rental_service_rev,
        sum(case when be.type in ('Retail Revenues') then be.amount else 0 end) as comp_retail_rev
    from {{ ref('stg_analytics_public__branch_earnings_dds_snap') }} as be
        inner join {{ ref('market') }} as m 
            on be.market_id = m.child_market_id
        inner join {{ ref('seed_account_targets_comp_markets') }} as cm
            on m.market_id = cm.market_id
    where date_trunc(month,be.gl_date) between (select start_date from comp_date_param) and (select end_date from comp_date_param)
    group by cm.comp_markets_id, date_trunc(month,be.gl_date)
),

monthly_comp_actuals as (
-- Get Monthly tota amounts by account
    select
        cm.comp_markets_id,
        date_trunc(month, be.gl_date) as gl_month,
        be.account_number as account_no,
        coalesce(pbm.sage_name, be.account_name) as account_name,
        coalesce(pbm.revexp, be.revenue_expense_category) as rev_exp,
        coalesce(pbm.display_name, be.type) as account_category,
        round(sum(case when coalesce(pbm.revexp, be.revenue_expense_category) = 'EXP'
                            and be.account_number not in('7806','BFEB') then coalesce(be.amount, 0) * -1
                    else coalesce(be.amount, 0) 
                end), 2) as comp_amount,
        cmm.comp_metric
    from {{ ref('stg_analytics_public__branch_earnings_dds_snap') }} as be
        inner join {{ ref('stg_analytics_gs__plexi_bucket_mapping') }} as pbm
            on be.account_number = pbm.sage_gl
        inner join {{ ref('seed_account_targets_account_comp_metric_map') }} as cmm
            on be.account_number = cmm.account_no
        inner join {{ ref('market') }} as m 
            on be.market_id = m.child_market_id
        inner join {{ ref('seed_account_targets_comp_markets') }} as cm
            on m.market_id = cm.market_id
    where date_trunc(month, be.gl_date) between (select start_date from comp_date_param) and (select end_date from comp_date_param)
    group by all
),

monthly_comp_metrics as (
-- Map on Comp OEC/Rev metrics based on comp_metric flag 
    select
        mca.*,
        (case
            when mca.comp_metric = 'Annualized % of OEC' then coalesce(oec.comp_rental_fleet_oec, 0)
            when mca.comp_metric = '% of Rental Revenue' then coalesce(rev.comp_rental_rev, 0)
            when mca.comp_metric = '% of Rental & Service Revenue' then coalesce(rev.comp_rental_service_rev, 0)
            when mca.comp_metric = '% of Retail Revenue' then coalesce(rev.comp_retail_rev, 0)
            when mca.comp_metric = '% of Total Revenue' then coalesce(rev.comp_total_rev, 0)
            else coalesce(rev.comp_total_rev, 0)
        end) as comp_metric_amount
    from monthly_comp_actuals as mca
        left join comp_monthly_oec as oec
            on mca.comp_markets_id = oec.comp_markets_id
                and mca.gl_month = oec.gl_month
        left join comp_monthly_revenues as rev
            on mca.comp_markets_id = rev.comp_markets_id
                and mca.gl_month = rev.gl_month
)

-- Aggregate the monthly amounts, annualizing any actuals tied to OEC as the comp metric
select
    comp_markets_id,
    account_no,
    account_name,
    rev_exp,
    account_category,
    comp_metric,
    sum(case when comp_metric = 'Annualized % of OEC' then comp_amount * 12
        else comp_amount end) / nullifzero(sum(comp_metric_amount)) as account_target
from monthly_comp_metrics
group by all

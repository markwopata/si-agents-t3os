
{% macro live_vs_static_be_comparison(month_year_comparison, month, fact_live_transactions_snapshot_date) %}
{#
    creates a snowflake table of live BE vs static BE. referenced in intacct_models/macros/be_live_vs_static_comparison.sql

    ARGS:
        month_year_comparison: 
            - the month and year you want to compare (i.e. April 2024)
        fact_live_transactions_snapshot_date:
            - the timestamp in the snapshot table run before static BE is run and wiped out (check intacct_models/seeds/seed_plexi_periods.csv for published_date)
            - run code to get official timestamp string of the day that BE is released:
                - select distinct dbt_valid_to from ANALYTICS.DBT_SNAPSHOTS.FACT_LIVE_TRANSACTIONS_SNAPSHOT where dbt_valid_to like '2024-05-21 %' (enter your date)
                - try to get it as close to official BE release time (see Slack message) 
                    - ie: SELECT CONVERT_TIMEZONE('UTC', 'America/Los_Angeles', '2024-05-21 17:15:55.935 +0000') AS pst_time and pick closest
        month:
            - enter in the month you want to compare (for the SQL field) (i.e. april)

        EXAMPLE
        {{ live_vs_static_be_comparison('April 2024', 'april', '2024-05-21 17:15:55.935 +0000') }}
#}

with be as (
    select 
        lb.account_number
        , round(sum(lb.amount), 2) as amount
    from {{ ref('stg_analytics_public__branch_earnings_dds_snap') }} lb
    inner join {{ ref('dim_date') }} dd 
        on lb.gl_date = dd.date
    inner join {{ ref('market') }} m
        on lb.market_id = m.child_market_id
    where 
        dd.period = '{{ month_year_comparison }}'
        and lb.account_number != 'BFAA'
    group by
        all
)

, live as (
    select 
        da.account_number
        , round(sum(lb.amount), 2) as amount
    from {{ ref('fact_live_transactions_snapshot') }} lb
    inner join {{ ref('dim_account') }} da 
        on lb.fk_account = da.pk_account
    inner join {{ ref('dim_date') }} dd 
        on lb.gl_date = dd.date
    inner join {{ ref('dim_market') }} dm
        on lb.fk_market = dm.pk_market
    inner join {{ ref('market') }} m
        on dm.market_id = m.child_market_id
    where 
        dd.period = '{{ month_year_comparison }}'
        and DA.ACCOUNT_NUMBER != 'BFAA'
        and dbt_valid_to = '{{ fact_live_transactions_snapshot_date }}'
    group by
        all
)

, aggregated as (
select 
    be.account_number
    , coalesce(pbm.sage_name, gla.account_name) as gl_account
    , round(sum(be.amount), 2)::double as {{month}}_be_amount
    , round(sum(live.amount), 2)::double as {{month}}_live_amount
    , abs(round({{month}}_be_amount - {{month}}_live_amount, 2)::double) as delta
    , div0(abs(delta), abs({{month}}_be_amount))::double * 100 as percent_change
    , sum({{month}}_be_amount) over() as total_{{month}}_be_amount
from be
left join live
    on be.account_number = live.account_number
inner join {{ ref('stg_analytics_gs__plexi_bucket_mapping') }} pbm
    on live.account_number = pbm.sage_gl
left join {{ ref('stg_analytics_intacct__gl_account') }} gla
    on live.account_number = gla.account_number
group by
    all
)

select
    *
from aggregated
order by 
    percent_change desc
{% endmacro %}
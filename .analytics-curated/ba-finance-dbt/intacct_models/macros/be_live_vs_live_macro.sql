{% macro live_vs_live_be_comparison(previous_month_year, live_month_year) %}
{#
creates a snowflake table of live BE vs live BE for previous and current month. referenced in intacct_models/models/marts/be_live_vs_live_review

    ARGS:
        previous_month_year: the previous month_year. i.e. if current month is May, enter in : April 2024
        live_month_year: the current live month_year i.e. if current month is May, enter in : May 2024
        
        
        EXAMPLE
        {{ live_vs_live_be_comparison('April 2024', 'May 2024') }}
#}

with prev_month_live as (
    select 
        da.account_number
        , round(sum(lb.amount), 2) as amount
    from {{ ref('fact_live_transactions') }} lb
    inner join {{ ref('dim_account') }} da 
        on lb.fk_account = da.pk_account
    inner join {{ ref('dim_date') }} dd 
        on lb.gl_date = dd.date
    inner join {{ ref('dim_market') }} dm 
        on lb.fk_market = dm.pk_market
    inner join {{ ref('market') }} m
        on dm.market_id = m.child_market_id
    where dd.period = '{{ previous_month_year }}'
        and da.account_number != 'BFAA'
    group by
        all
)

, current_month_live as (
    select 
        da.account_number
        , round(sum(lb.amount), 2) as amount
    from {{ ref('fact_live_transactions') }} lb
    inner join {{ ref('dim_account') }} da 
        on lb.fk_account = da.pk_account
    inner join {{ ref('dim_date') }} dd 
        on lb.gl_date = dd.date
    inner join {{ ref('dim_market') }} dm
        on lb.fk_market = dm.pk_market
    inner join {{ ref('market') }} m
        on dm.market_id = m.child_market_id
    where dd.period = '{{ live_month_year }}'
        and da.account_number != 'BFAA'
    group by
        all
) 

select 
    p.account_number
    , coalesce(pbm.sage_name, gla.account_name) as gl_account
    , round(sum(c.amount), 2) as current_month_live_amount
    , round(sum(p.amount), 2) as prev_month_live_amount
    , abs(round(current_month_live_amount - prev_month_live_amount, 2)) as delta
    , div0(abs(delta), abs(prev_month_live_amount))::double * 100 as pct_delta
from prev_month_live p
left join current_month_live c
    on c.account_number = p.account_number
inner join {{ ref('stg_analytics_gs__plexi_bucket_mapping') }} pbm
    on p.account_number = pbm.sage_gl
left join {{ ref('stg_analytics_intacct__gl_account') }} gla
    on p.account_number = gla.account_number
group by 
    all
order by 
    pct_delta asc

{% endmacro %}
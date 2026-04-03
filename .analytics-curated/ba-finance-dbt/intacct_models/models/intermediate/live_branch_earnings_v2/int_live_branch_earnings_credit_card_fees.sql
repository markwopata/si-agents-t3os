with most_recent_static_month as (
    select date_trunc(month, max(gl_date)) as most_recent_static_month
    from {{ ref("stg_analytics_public__branch_earnings_dds_snap") }}
),

monthly_avg as (
    select
        beds.market_id,
        round(sum(beds.amount) / 3, 0) as amount
    from {{ ref("stg_analytics_public__branch_earnings_dds_snap") }} as beds,
        most_recent_static_month as mrsm
    where beds.account_number = '7101'
        and dateadd(month, -3, date_trunc(month, mrsm.most_recent_static_month)) < date_trunc(month, beds.gl_date)
    group by 1
    order by 1
)

select
    monthly_avg.market_id,
    '7101' as account_number,
    'Market ID | GL Date' as transaction_number_format,
    monthly_avg.market_id || '|' || gl_months.datelist::varchar as transaction_number,
    'Credit card fees estimated from previous 3 month average' as description,
    gl_months.datelist as gl_date,
    'Market' as document_type,
    monthly_avg.market_id as document_number,
    null as url_sage,
    null as url_concur,
    null as url_admin,
    null as url_t3,
    monthly_avg.amount,
    object_construct() as additional_data,
    'DDS' as source,
    'Credit Card Fees' as load_section,
    '{{ this.name }}' as source_model
from monthly_avg, ({{ live_be_period_firstday_of_each_month() }}) as gl_months
where monthly_avg.amount < 0

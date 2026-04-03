with
dds_snap as (
    select
        market_id,
        account_number,
        sum(amount) as amount,
        date_trunc(month, gl_date) as gl_date
    from {{ ref("stg_analytics_public__branch_earnings_dds_snap") }}
    where date_trunc(month, gl_date) = '{{ last_branch_earnings_published_date() }}'
        and account_number in ('BFEB')
    group by market_id, account_number, date_trunc(month, gl_date)
),

formatted_data as (
    select
        dds_snap.market_id,
        dds_snap.account_number,
        'DDS' as transaction_number_format,
        null as transaction_number,
        'Machine Make Ready Estimate from Previous Month' as description,
        first_of_the_month.datelist::date as gl_date,
        'DDS' as document_type,
        null as document_number,
        null as url_sage,
        null as url_concur,
        null as url_admin,
        null as url_t3,
        dds_snap.amount,
        object_construct() as additional_data,
        'DDS SNAP' as source,
        'Machine Make Ready' as load_section,
        '{{ this.name }}' as source_model
    from dds_snap, ({{ live_be_period_firstday_of_each_month() }}) as first_of_the_month

)

select *
from formatted_data

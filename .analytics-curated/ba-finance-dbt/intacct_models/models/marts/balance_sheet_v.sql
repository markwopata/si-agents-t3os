{{
    config(materialized='view',
        persist_docs={'columns': false}
    )
 }}
with account_months as (
    select
        gla.account_number,
        month_
    from {{ ref('stg_analytics_intacct__gl_account') }} as gla
        inner join (
            select t.series::date as month_
            from table(ES_WAREHOUSE.PUBLIC.GENERATE_SERIES(
                '2016-12-01'::timestamp_tz,
                date_trunc(
                    month, add_months(current_date(), 1)
                )::timestamp_tz,
                'month'
            )) as t
        ) as dates
    where account_type = 'balancesheet'
),

data as (
    select
        am.account_number,
        gla.account_name as account_title,
        am.month_ as period_start_date,
        sum(sum(coalesce(gd.amount, 0)))
            over (
                partition by
                    am.account_number, gla.account_name, gla.account_category
                order by date_trunc(month, am.month_)
            )
            as amount,
        gla.account_category as category
    from account_months as am
        left join {{ ref('gl_detail') }} as gd
            on
                am.account_number = gd.account_number
                and am.month_ = date_trunc(month, gd.entry_date)
        inner join {{ ref('stg_analytics_intacct__gl_account') }} as gla
            on am.account_number = gla.account_number
    where 1 = 1
    group by
        am.account_number, gla.account_name, am.month_, gla.account_category
)

select
    account_number,
    account_title,
    period_start_date,
    sum(amount) as amount,
    category
from data
where
    1 = 1
    and period_start_date < date_trunc(month, add_months(current_date(), 1))
group by account_number, account_title, period_start_date, category
order by period_start_date, account_number

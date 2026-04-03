{{
    config(materialized='view',
        persist_docs={'columns': false}
    )
 }}
with account_months as (
    select
        month_,
        account_number,
        department_id,
        department_name,
        entity_id,
        entity_name
    from (select distinct
        account_number,
        department_id,
        department_name,
        entity_id,
        entity_name
    from {{ ref('gl_detail') }}
    where account_type = 'balancesheet') as accounts
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
),

aggregated_data as (
    select
        am.account_number as account_number,
        gla.account_name as account_title,
        am.month_ as period_start_date,
        coalesce(sum(sum(gd.amount))
            over (
                partition by
                    am.account_number,
                    gla.account_name,
                    gla.account_category,
                    am.department_id,
                    am.department_name,
                    am.entity_id,
                    am.entity_name
                order by
                    period_start_date,
                    am.account_number,
                    am.entity_id,
                    am.department_id
            ),
        0) as amount,
        gla.account_category as category,
        am.department_id,
        am.department_name,
        am.entity_id,
        am.entity_name
    from account_months as am
        left join {{ ref('gl_detail') }} as gd
            on
                am.account_number = gd.account_number
                and am.month_ = date_trunc(month, gd.entry_date)
                and (
                    am.department_id = gd.department_id
                    or (
                        am.department_id is null and gd.department_id is null
                    )
                )
                and am.entity_id = gd.entity_id
        inner join {{ ref('stg_analytics_intacct__gl_account') }} as gla
            on am.account_number = gla.account_number
    where 1 = 1
    group by
        am.account_number,
        gla.account_name,
        am.month_,
        gla.account_category,
        am.department_id,
        am.department_name, am.entity_id, am.entity_name
)

select
    account_number,
    account_title,
    period_start_date,
    round(sum(amount), 2) as amount,
    category,
    department_id,
    department_name as department_title,
    entity_id,
    entity_name
from aggregated_data
where
    1 = 1
    and period_start_date < date_trunc(month, add_months(current_date(), 1))
group by
    account_number,
    account_title,
    period_start_date,
    category,
    department_id,
    department_name,
    entity_id, entity_name
order by period_start_date, account_number, entity_id, department_id

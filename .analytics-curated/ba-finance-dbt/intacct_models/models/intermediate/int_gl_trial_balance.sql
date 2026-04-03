-- Explode out combinations of account_number, entity_id, department_id, period_start_date since 2016.
with account_department_entity_combos as (
    select distinct
        gd.account_number,
        gd.entity_id,
        gd.entity_name,
        gd.department_id,
        gd.department_name
    from {{ ref("gl_detail") }} as gd
),

months as (
    select t.series::date as period_start_date
    from table(
        es_warehouse.public.generate_series(
            '2016-12-01'::timestamp_tz,
            date_trunc(month, add_months(current_date(), 1))::timestamp_tz,
            'month'
        )
    ) as t
),

account_months as (
    select
        m.period_start_date,
        a.account_number,
        a.entity_id,
        a.entity_name,
        a.department_name,
        a.department_id
    from account_department_entity_combos as a
        cross join months as m
),

-- Aggregate GL detail for monthly activity
gl_monthly as (
    select
        date_trunc(month, gd.entry_date) as period_start_date,
        gd.account_number,
        gd.entity_id,
        gd.department_id,
        sum(case when gd.debit_credit = 'debit' then gd.raw_amount else 0 end) as debit_amount,
        sum(case when gd.debit_credit = 'credit' then gd.raw_amount else 0 end) as credit_amount,
        sum(gd.raw_amount * gd.debit_credit_sign) as net_activity -- debits-credits
    from {{ ref("gl_detail") }} as gd
    group by all
),

-- Join the exploded account-month-etc combos with monthly GL detail, so we get 0s for months missing GL detail
joined as (
    select
        am.period_start_date,
        am.account_number,
        gla.account_name,
        gla.account_category,
        gla.account_type,
        am.entity_id,
        am.entity_name,
        am.department_id,
        am.department_name,
        coalesce(gm.debit_amount, 0) as debit_amount,
        coalesce(gm.credit_amount, 0) as credit_amount,
        coalesce(gm.net_activity, 0) as net_activity
    from account_months as am
        inner join {{ ref("stg_analytics_intacct__gl_account") }} as gla
            on am.account_number = gla.account_number
        left join gl_monthly as gm
            on am.account_number = gm.account_number
                and am.period_start_date = gm.period_start_date
                and (
                    -- ** This join has an odd structure, might need to revisit **
                    am.department_id = gm.department_id
                    or (am.department_id is null and gm.department_id is null)
                )
                and am.entity_id = gm.entity_id
),

-- Add a cumulative ending balance. For income statement, we need to reset yearly.
add_cumulative_ending_balance as (
    select
        j.*,
        sum(j.net_activity) over (
            partition by
                j.account_number,
                j.entity_id,
                j.department_id,
                case
                    when j.account_type = 'incomestatement'
                        then year(j.period_start_date)
                    else 0
                end
            order by j.period_start_date, j.account_number, j.entity_id, j.department_id
        ) as ending_balance
    from joined as j
),

-- Derive beginning balance from previous ending.
out as (
    select
        md5(
            aceb.period_start_date::text
            || coalesce(aceb.entity_id, 'no entity id')
            || coalesce(aceb.department_id, 'no department id')
            || aceb.account_number
        ) as pk_gl_trial_balance_id,
        aceb.period_start_date,
        aceb.entity_id,
        aceb.entity_name,
        aceb.department_id,
        aceb.department_name,
        aceb.account_number,
        aceb.account_name,
        aceb.account_category,
        aceb.account_type,
        coalesce(
            lag(aceb.ending_balance) over (
                partition by
                    aceb.account_number,
                    aceb.entity_id,
                    aceb.department_id,
                    case
                        when aceb.account_type = 'incomestatement'
                            then year(aceb.period_start_date)
                        else 0
                    end
                order by aceb.period_start_date
            ), 0
        ) as beginning_balance,
        aceb.debit_amount,
        aceb.credit_amount,
        aceb.net_activity,
        aceb.ending_balance
    from add_cumulative_ending_balance as aceb
    where aceb.period_start_date < date_trunc(month, add_months(current_date(), 1))
)

select *
from out
order by period_start_date, account_number, entity_id, department_id

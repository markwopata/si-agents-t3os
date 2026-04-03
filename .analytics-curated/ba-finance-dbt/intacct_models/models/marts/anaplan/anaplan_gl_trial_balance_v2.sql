with base as (
    select *
    from {{ ref('anaplan_gl_trial_balance') }}
),

non_re as (
    select
        pk_gl_trial_balance_id,
        period_start_date,
        entity_id,
        entity_name,
        coalesce(department_id, 'No department_id') as department_id,
        coalesce(department_name, 'No department_name') as department_name,
        account_number,
        account_name,
        account_type,
        account_category,
        account_number || '_' || coalesce(department_id, 'No department_id') as segment_helper,
        ending_balance::number(38, 2) as ending_balance
    from base
    where account_number != '3900'
),

-- December anchor
last_december_anchor as (
    select
        entity_id,
        department_id,
        year(period_start_date) + 1 as fiscal_year,
        ending_balance as last_december_re
    from base
    where account_number = '3900'
        and month(period_start_date) = 12
),

-- Monthly RE adjustments from retained earnings entries
re_adj_month as (
    select
        date_trunc(month, gd.raw_entry_date) as period_start_date, -- Place in actual month of adj
        gd.entity_id,
        gd.department_id,
        sum(gd.raw_amount * gd.debit_credit_sign)::number(38, 2) as re_adj_net_activity
    from {{ ref('gl_detail') }} as gd
    where gd.account_number = '3900'
        and gd.source ilike '%retained earnings entries%'
        and year(gd.entry_date) = year(gd.raw_entry_date) -- if Jan raw_entry_date, already counted in prior year Dec
    group by period_start_date, gd.entity_id, gd.department_id
),

-- Final RE per month = December anchor + YTD adjustments
re as (
    select
        b.pk_gl_trial_balance_id,
        b.period_start_date,
        b.entity_id,
        b.entity_name,
        coalesce(b.department_id, 'No department_id') as department_id,
        coalesce(b.department_name, 'No department_name') as department_name,
        b.account_number,
        b.account_name,
        b.account_type,
        b.account_category,
        b.account_number || '_' || coalesce(b.department_id, 'No department_id') as segment_helper,

        -- Need to do partition per entity/department/year so RE adjustments cumulative sum
        -- Should alays have last december but if not use month ending balance without manual adjustment
        (
            case
                when a.last_december_re is not null
                    then
                        a.last_december_re
                        + sum(coalesce(m.re_adj_net_activity, 0)) over (
                            partition by b.entity_id, b.department_id, year(b.period_start_date)
                            order by b.period_start_date
                        )
                else
                    b.ending_balance
            end
        )::number(38, 2) as ending_balance

    from base as b
        left join last_december_anchor as a
            on b.entity_id = a.entity_id
                and (
                    -- ** This join has an odd structure, might need to revisit **
                    b.department_id = a.department_id
                    or (b.department_id is null and a.department_id is null)
                )
                and year(b.period_start_date) = a.fiscal_year
        left join re_adj_month as m
            on b.period_start_date = m.period_start_date
                and b.entity_id = m.entity_id
                and (
                    -- ** This join has an odd structure, might need to revisit **
                    b.department_id = m.department_id
                    or (b.department_id is null and m.department_id is null)
                )
    where b.account_number = '3900'
),

out as (
    select * from non_re
    union all
    select * from re
)

select *
from out
where period_start_date >= '2021-01-01'
order by period_start_date, account_number, entity_id, department_id

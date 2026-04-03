{{
    config(
        materialized='table',
        cluster_by=['asset_id', 'rental_id']
    )
}}

-- Period Utilization Report
-- Calculates utilization for different time periods based on run_time_cst
-- Utilization = run_time / (number of possible days * 8 hours in a day)
-- run_time is in seconds, so: run_time_seconds / (possible_days * 8 * 3600)

with daily_utilization as (
    select
        rental_id,
        asset_id,
        date,
        run_time_cst,
        possible_utilization_days,
        coalesce(shift_type_id, 1) as shift_type_id
    from {{ ref('stg_t3__by_day_utilization') }}
    where rental_id is not null
        and asset_id is not null
),

-- Past 7 days
past_7_days as (
    select
        rental_id,
        asset_id,
        shift_type_id,
        'past_7_days' as period_type,
        dateadd(day, -7, current_date()) as period_start_date,
        current_date() as period_end_date,
        sum(run_time_cst) as total_run_time_seconds,
        sum(possible_utilization_days) as total_possible_days
    from daily_utilization
    where date >= dateadd(day, -7, current_date())
    group by rental_id, asset_id, shift_type_id
),

-- Past 28 days
past_28_days as (
    select
        rental_id,
        asset_id,
        shift_type_id,
        'past_28_days' as period_type,
        dateadd(day, -28, current_date()) as period_start_date,
        current_date() as period_end_date,
        sum(run_time_cst) as total_run_time_seconds,
        sum(possible_utilization_days) as total_possible_days
    from daily_utilization
    where date >= dateadd(day, -28, current_date())
    group by rental_id, asset_id, shift_type_id
),

-- This week (Monday to Sunday)
this_week as (
    select
        rental_id,
        asset_id,
        shift_type_id,
        'this_week' as period_type,
        date_trunc('week', current_date()) as period_start_date,
        dateadd(day, 6, date_trunc('week', current_date())) as period_end_date,
        sum(run_time_cst) as total_run_time_seconds,
        sum(possible_utilization_days) as total_possible_days
    from daily_utilization
    where date >= date_trunc('week', current_date())
        and date <= dateadd(day, 6, date_trunc('week', current_date()))
    group by rental_id, asset_id, shift_type_id
),

-- Last week (previous Monday to Sunday)
last_week as (
    select
        rental_id,
        asset_id,
        shift_type_id,
        'last_week' as period_type,
        dateadd(week, -1, date_trunc('week', current_date())) as period_start_date,
        dateadd(day, 6, dateadd(week, -1, date_trunc('week', current_date()))) as period_end_date,
        sum(run_time_cst) as total_run_time_seconds,
        sum(possible_utilization_days) as total_possible_days
    from daily_utilization
    where date >= dateadd(week, -1, date_trunc('week', current_date()))
        and date <= dateadd(day, 6, dateadd(week, -1, date_trunc('week', current_date())))
    group by rental_id, asset_id, shift_type_id
),

-- This week to date
this_week_to_date as (
    select
        rental_id,
        asset_id,
        shift_type_id,
        'this_week_to_date' as period_type,
        date_trunc('week', current_date()) as period_start_date,
        current_date() as period_end_date,
        sum(run_time_cst) as total_run_time_seconds,
        sum(possible_utilization_days) as total_possible_days
    from daily_utilization
    where date >= date_trunc('week', current_date())
        and date <= current_date()
    group by rental_id, asset_id, shift_type_id
),

-- Last week to date (same day of week last week)
last_week_to_date as (
    select
        rental_id,
        asset_id,
        shift_type_id,
        'last_week_to_date' as period_type,
        dateadd(week, -1, date_trunc('week', current_date())) as period_start_date,
        dateadd(week, -1, current_date()) as period_end_date,
        sum(run_time_cst) as total_run_time_seconds,
        sum(possible_utilization_days) as total_possible_days
    from daily_utilization
    where date >= dateadd(week, -1, date_trunc('week', current_date()))
        and date <= dateadd(week, -1, current_date())
    group by rental_id, asset_id, shift_type_id
),

-- This month
this_month as (
    select
        rental_id,
        asset_id,
        shift_type_id,
        'this_month' as period_type,
        date_trunc('month', current_date()) as period_start_date,
        last_day(current_date()) as period_end_date,
        sum(run_time_cst) as total_run_time_seconds,
        sum(possible_utilization_days) as total_possible_days
    from daily_utilization
    where date >= date_trunc('month', current_date())
        and date <= last_day(current_date())
    group by rental_id, asset_id, shift_type_id
),

-- Last month
last_month as (
    select
        rental_id,
        asset_id,
        shift_type_id,
        'last_month' as period_type,
        date_trunc('month', dateadd('month', -1, current_date())) as period_start_date,
        last_day(dateadd('month', -1, current_date())) as period_end_date,
        sum(run_time_cst) as total_run_time_seconds,
        sum(possible_utilization_days) as total_possible_days
    from daily_utilization
    where date >= date_trunc('month', dateadd('month', -1, current_date()))
        and date <= last_day(dateadd('month', -1, current_date()))
    group by rental_id, asset_id, shift_type_id
),

-- This month to date
this_month_to_date as (
    select
        rental_id,
        asset_id,
        shift_type_id,
        'this_month_to_date' as period_type,
        date_trunc('month', current_date()) as period_start_date,
        current_date() as period_end_date,
        sum(run_time_cst) as total_run_time_seconds,
        sum(possible_utilization_days) as total_possible_days
    from daily_utilization
    where date >= date_trunc('month', current_date())
        and date <= current_date()
    group by rental_id, asset_id, shift_type_id
),

-- Last month to date (same date range as last month, but up to the same day last month)
last_month_to_date as (
    select
        rental_id,
        asset_id,
        shift_type_id,
        'last_month_to_date' as period_type,
        date_trunc('month', dateadd('month', -1, current_date())) as period_start_date,
        dateadd('month', -1, current_date()) as period_end_date,
        sum(run_time_cst) as total_run_time_seconds,
        sum(possible_utilization_days) as total_possible_days
    from daily_utilization
    where date >= date_trunc('month', dateadd('month', -1, current_date()))
        and date <= dateadd('month', -1, current_date())
    group by rental_id, asset_id, shift_type_id
),

-- This quarter
this_quarter as (
    select
        rental_id,
        asset_id,
        shift_type_id,
        'this_quarter' as period_type,
        date_trunc('quarter', current_date()) as period_start_date,
        last_day(dateadd('month', 2, date_trunc('quarter', current_date()))) as period_end_date,
        sum(run_time_cst) as total_run_time_seconds,
        sum(possible_utilization_days) as total_possible_days
    from daily_utilization
    where date >= date_trunc('quarter', current_date())
        and date <= last_day(dateadd('month', 2, date_trunc('quarter', current_date())))
    group by rental_id, asset_id, shift_type_id
),

-- Last quarter
last_quarter as (
    select
        rental_id,
        asset_id,
        shift_type_id,
        'last_quarter' as period_type,
        date_trunc('quarter', dateadd('quarter', -1, current_date())) as period_start_date,
        last_day(dateadd('month', 2, date_trunc('quarter', dateadd('quarter', -1, current_date())))) as period_end_date,
        sum(run_time_cst) as total_run_time_seconds,
        sum(possible_utilization_days) as total_possible_days
    from daily_utilization
    where date >= date_trunc('quarter', dateadd('quarter', -1, current_date()))
        and date <= last_day(dateadd('month', 2, date_trunc('quarter', dateadd('quarter', -1, current_date()))))
    group by rental_id, asset_id, shift_type_id
),

-- This quarter to date
this_quarter_to_date as (
    select
        rental_id,
        asset_id,
        shift_type_id,
        'this_quarter_to_date' as period_type,
        date_trunc('quarter', current_date()) as period_start_date,
        current_date() as period_end_date,
        sum(run_time_cst) as total_run_time_seconds,
        sum(possible_utilization_days) as total_possible_days
    from daily_utilization
    where date >= date_trunc('quarter', current_date())
        and date <= current_date()
    group by rental_id, asset_id, shift_type_id
),

-- Last quarter to date (same date range as last quarter, but up to the same day last quarter)
last_quarter_to_date as (
    select
        rental_id,
        asset_id,
        shift_type_id,
        'last_quarter_to_date' as period_type,
        date_trunc('quarter', dateadd('quarter', -1, current_date())) as period_start_date,
        dateadd('quarter', -1, current_date()) as period_end_date,
        sum(run_time_cst) as total_run_time_seconds,
        sum(possible_utilization_days) as total_possible_days
    from daily_utilization
    where date >= date_trunc('quarter', dateadd('quarter', -1, current_date()))
        and date <= dateadd('quarter', -1, current_date())
    group by rental_id, asset_id, shift_type_id
),

-- This year
this_year as (
    select
        rental_id,
        asset_id,
        shift_type_id,
        'this_year' as period_type,
        date_trunc('year', current_date()) as period_start_date,
        last_day(dateadd('month', 11, date_trunc('year', current_date()))) as period_end_date,
        sum(run_time_cst) as total_run_time_seconds,
        sum(possible_utilization_days) as total_possible_days
    from daily_utilization
    where date >= date_trunc('year', current_date())
        and date <= last_day(dateadd('month', 11, date_trunc('year', current_date())))
    group by rental_id, asset_id, shift_type_id
),

-- Last year
last_year as (
    select
        rental_id,
        asset_id,
        shift_type_id,
        'last_year' as period_type,
        date_trunc('year', dateadd('year', -1, current_date())) as period_start_date,
        last_day(dateadd('month', 11, date_trunc('year', dateadd('year', -1, current_date())))) as period_end_date,
        sum(run_time_cst) as total_run_time_seconds,
        sum(possible_utilization_days) as total_possible_days
    from daily_utilization
    where date >= date_trunc('year', dateadd('year', -1, current_date()))
        and date <= last_day(dateadd('month', 11, date_trunc('year', dateadd('year', -1, current_date()))))
    group by rental_id, asset_id, shift_type_id
),

-- This year to date
this_year_to_date as (
    select
        rental_id,
        asset_id,
        shift_type_id,
        'this_year_to_date' as period_type,
        date_trunc('year', current_date()) as period_start_date,
        current_date() as period_end_date,
        sum(run_time_cst) as total_run_time_seconds,
        sum(possible_utilization_days) as total_possible_days
    from daily_utilization
    where date >= date_trunc('year', current_date())
        and date <= current_date()
    group by rental_id, asset_id, shift_type_id
),

-- Last year to date (same date range as last year, but up to the same day last year)
last_year_to_date as (
    select
        rental_id,
        asset_id,
        shift_type_id,
        'last_year_to_date' as period_type,
        date_trunc('year', dateadd('year', -1, current_date())) as period_start_date,
        dateadd('year', -1, current_date()) as period_end_date,
        sum(run_time_cst) as total_run_time_seconds,
        sum(possible_utilization_days) as total_possible_days
    from daily_utilization
    where date >= date_trunc('year', dateadd('year', -1, current_date()))
        and date <= dateadd('year', -1, current_date())
    group by rental_id, asset_id, shift_type_id
),

-- Last year this week (same week number from last year)
last_year_this_week as (
    select
        rental_id,
        asset_id,
        shift_type_id,
        'last_year_this_week' as period_type,
        dateadd('year', -1, date_trunc('week', current_date())) as period_start_date,
        dateadd(day, 6, dateadd('year', -1, date_trunc('week', current_date()))) as period_end_date,
        sum(run_time_cst) as total_run_time_seconds,
        sum(possible_utilization_days) as total_possible_days
    from daily_utilization
    where date >= dateadd('year', -1, date_trunc('week', current_date()))
        and date <= dateadd(day, 6, dateadd('year', -1, date_trunc('week', current_date())))
    group by rental_id, asset_id, shift_type_id
),

-- Last year this month (same calendar month from last year)
last_year_this_month as (
    select
        rental_id,
        asset_id,
        shift_type_id,
        'last_year_this_month' as period_type,
        dateadd('year', -1, date_trunc('month', current_date())) as period_start_date,
        last_day(dateadd('year', -1, date_trunc('month', current_date()))) as period_end_date,
        sum(run_time_cst) as total_run_time_seconds,
        sum(possible_utilization_days) as total_possible_days
    from daily_utilization
    where date >= dateadd('year', -1, date_trunc('month', current_date()))
        and date <= last_day(dateadd('year', -1, date_trunc('month', current_date())))
    group by rental_id, asset_id, shift_type_id
),

-- Last year this month to date (same calendar month to date from last year)
last_year_this_month_to_date as (
    select
        rental_id,
        asset_id,
        shift_type_id,
        'last_year_this_month_to_date' as period_type,
        dateadd('year', -1, date_trunc('month', current_date())) as period_start_date,
        dateadd('year', -1, current_date()) as period_end_date,
        sum(run_time_cst) as total_run_time_seconds,
        sum(possible_utilization_days) as total_possible_days
    from daily_utilization
    where date >= dateadd('year', -1, date_trunc('month', current_date()))
        and date <= dateadd('year', -1, current_date())
    group by rental_id, asset_id, shift_type_id
),

-- Combine all periods
all_periods as (
    select * from past_7_days
    union all
    select * from past_28_days
    union all
    select * from this_week
    union all
    select * from last_week
    union all
    select * from this_week_to_date
    union all
    select * from last_week_to_date
    union all
    select * from this_month
    union all
    select * from last_month
    union all
    select * from this_month_to_date
    union all
    select * from last_month_to_date
    union all
    select * from this_quarter
    union all
    select * from last_quarter
    union all
    select * from this_quarter_to_date
    union all
    select * from last_quarter_to_date
    union all
    select * from this_year
    union all
    select * from last_year
    union all
    select * from this_year_to_date
    union all
    select * from last_year_to_date
    union all
    select * from last_year_this_week
    union all
    select * from last_year_this_month
    union all
    select * from last_year_this_month_to_date
),

period_metrics as (
    select
        rental_id,
        asset_id,
        shift_type_id,
        period_type,
        total_run_time_seconds,
        total_possible_days,
        -- Calculate hours per day based on shift_type_id: 3 = 24 hours, 2 = 16 hours, else 8 hours
        case
            when shift_type_id = 3 then 24.0
            when shift_type_id = 2 then 16.0
            else 8.0
        end as hours_per_day,
        -- Calculate total possible hours based on shift type
        total_possible_days * case
            when shift_type_id = 3 then 24.0
            when shift_type_id = 2 then 16.0
            else 8.0
        end as total_possible_hours,
        -- Calculate utilization: run_time / (possible_days * hours_per_day * 3600 seconds)
        case
            when total_possible_days > 0 
                and (total_possible_days * case
                    when shift_type_id = 3 then 24.0
                    when shift_type_id = 2 then 16.0
                    else 8.0
                end * 3600) > 0
            then total_run_time_seconds / (total_possible_days * case
                when shift_type_id = 3 then 24.0
                when shift_type_id = 2 then 16.0
                else 8.0
            end * 3600.0)
            else 0
        end as utilization,
        -- Also provide run_time in hours for convenience
        total_run_time_seconds / 3600.0 as total_run_time_hours
    from all_periods
)

select
    rental_id,
    asset_id,
    shift_type_id,
    -- Past 7 days columns
    max(case when pm.period_type = 'past_7_days' then pm.utilization end) as past_7_days_utilization,
    max(case when pm.period_type = 'past_7_days' then pm.total_run_time_hours end) as past_7_days_run_time_hours,
    max(case when pm.period_type = 'past_7_days' then pm.total_possible_hours end) as past_7_days_possible_hours,
    max(case when pm.period_type = 'past_7_days' then pm.total_possible_days end) as past_7_days_possible_days,
    -- Past 28 days columns
    max(case when pm.period_type = 'past_28_days' then pm.utilization end) as past_28_days_utilization,
    max(case when pm.period_type = 'past_28_days' then pm.total_run_time_hours end) as past_28_days_run_time_hours,
    max(case when pm.period_type = 'past_28_days' then pm.total_possible_hours end) as past_28_days_possible_hours,
    max(case when pm.period_type = 'past_28_days' then pm.total_possible_days end) as past_28_days_possible_days,
    -- This week columns
    max(case when pm.period_type = 'this_week' then pm.utilization end) as this_week_utilization,
    max(case when pm.period_type = 'this_week' then pm.total_run_time_hours end) as this_week_run_time_hours,
    max(case when pm.period_type = 'this_week' then pm.total_possible_hours end) as this_week_possible_hours,
    max(case when pm.period_type = 'this_week' then pm.total_possible_days end) as this_week_possible_days,
    -- Last week columns
    max(case when pm.period_type = 'last_week' then pm.utilization end) as last_week_utilization,
    max(case when pm.period_type = 'last_week' then pm.total_run_time_hours end) as last_week_run_time_hours,
    max(case when pm.period_type = 'last_week' then pm.total_possible_hours end) as last_week_possible_hours,
    max(case when pm.period_type = 'last_week' then pm.total_possible_days end) as last_week_possible_days,
    -- This week to date columns
    max(case when pm.period_type = 'this_week_to_date' then pm.utilization end) as this_week_to_date_utilization,
    max(case when pm.period_type = 'this_week_to_date' then pm.total_run_time_hours end) as this_week_to_date_run_time_hours,
    max(case when pm.period_type = 'this_week_to_date' then pm.total_possible_hours end) as this_week_to_date_possible_hours,
    max(case when pm.period_type = 'this_week_to_date' then pm.total_possible_days end) as this_week_to_date_possible_days,
    -- Last week to date columns
    max(case when pm.period_type = 'last_week_to_date' then pm.utilization end) as last_week_to_date_utilization,
    max(case when pm.period_type = 'last_week_to_date' then pm.total_run_time_hours end) as last_week_to_date_run_time_hours,
    max(case when pm.period_type = 'last_week_to_date' then pm.total_possible_hours end) as last_week_to_date_possible_hours,
    max(case when pm.period_type = 'last_week_to_date' then pm.total_possible_days end) as last_week_to_date_possible_days,
    -- This month columns
    max(case when pm.period_type = 'this_month' then pm.utilization end) as this_month_utilization,
    max(case when pm.period_type = 'this_month' then pm.total_run_time_hours end) as this_month_run_time_hours,
    max(case when pm.period_type = 'this_month' then pm.total_possible_hours end) as this_month_possible_hours,
    max(case when pm.period_type = 'this_month' then pm.total_possible_days end) as this_month_possible_days,
    -- Last month columns
    max(case when pm.period_type = 'last_month' then pm.utilization end) as last_month_utilization,
    max(case when pm.period_type = 'last_month' then pm.total_run_time_hours end) as last_month_run_time_hours,
    max(case when pm.period_type = 'last_month' then pm.total_possible_hours end) as last_month_possible_hours,
    max(case when pm.period_type = 'last_month' then pm.total_possible_days end) as last_month_possible_days,
    -- This month to date columns
    max(case when pm.period_type = 'this_month_to_date' then pm.utilization end) as this_month_to_date_utilization,
    max(case when pm.period_type = 'this_month_to_date' then pm.total_run_time_hours end) as this_month_to_date_run_time_hours,
    max(case when pm.period_type = 'this_month_to_date' then pm.total_possible_hours end) as this_month_to_date_possible_hours,
    max(case when pm.period_type = 'this_month_to_date' then pm.total_possible_days end) as this_month_to_date_possible_days,
    -- Last month to date columns
    max(case when pm.period_type = 'last_month_to_date' then pm.utilization end) as last_month_to_date_utilization,
    max(case when pm.period_type = 'last_month_to_date' then pm.total_run_time_hours end) as last_month_to_date_run_time_hours,
    max(case when pm.period_type = 'last_month_to_date' then pm.total_possible_hours end) as last_month_to_date_possible_hours,
    max(case when pm.period_type = 'last_month_to_date' then pm.total_possible_days end) as last_month_to_date_possible_days,
    -- This quarter columns
    max(case when pm.period_type = 'this_quarter' then pm.utilization end) as this_quarter_utilization,
    max(case when pm.period_type = 'this_quarter' then pm.total_run_time_hours end) as this_quarter_run_time_hours,
    max(case when pm.period_type = 'this_quarter' then pm.total_possible_hours end) as this_quarter_possible_hours,
    max(case when pm.period_type = 'this_quarter' then pm.total_possible_days end) as this_quarter_possible_days,
    -- Last quarter columns
    max(case when pm.period_type = 'last_quarter' then pm.utilization end) as last_quarter_utilization,
    max(case when pm.period_type = 'last_quarter' then pm.total_run_time_hours end) as last_quarter_run_time_hours,
    max(case when pm.period_type = 'last_quarter' then pm.total_possible_hours end) as last_quarter_possible_hours,
    max(case when pm.period_type = 'last_quarter' then pm.total_possible_days end) as last_quarter_possible_days,
    -- This quarter to date columns
    max(case when pm.period_type = 'this_quarter_to_date' then pm.utilization end) as this_quarter_to_date_utilization,
    max(case when pm.period_type = 'this_quarter_to_date' then pm.total_run_time_hours end) as this_quarter_to_date_run_time_hours,
    max(case when pm.period_type = 'this_quarter_to_date' then pm.total_possible_hours end) as this_quarter_to_date_possible_hours,
    max(case when pm.period_type = 'this_quarter_to_date' then pm.total_possible_days end) as this_quarter_to_date_possible_days,
    -- Last quarter to date columns
    max(case when pm.period_type = 'last_quarter_to_date' then pm.utilization end) as last_quarter_to_date_utilization,
    max(case when pm.period_type = 'last_quarter_to_date' then pm.total_run_time_hours end) as last_quarter_to_date_run_time_hours,
    max(case when pm.period_type = 'last_quarter_to_date' then pm.total_possible_hours end) as last_quarter_to_date_possible_hours,
    max(case when pm.period_type = 'last_quarter_to_date' then pm.total_possible_days end) as last_quarter_to_date_possible_days,
    -- This year columns
    max(case when pm.period_type = 'this_year' then pm.utilization end) as this_year_utilization,
    max(case when pm.period_type = 'this_year' then pm.total_run_time_hours end) as this_year_run_time_hours,
    max(case when pm.period_type = 'this_year' then pm.total_possible_hours end) as this_year_possible_hours,
    max(case when pm.period_type = 'this_year' then pm.total_possible_days end) as this_year_possible_days,
    -- Last year columns
    max(case when pm.period_type = 'last_year' then pm.utilization end) as last_year_utilization,
    max(case when pm.period_type = 'last_year' then pm.total_run_time_hours end) as last_year_run_time_hours,
    max(case when pm.period_type = 'last_year' then pm.total_possible_hours end) as last_year_possible_hours,
    max(case when pm.period_type = 'last_year' then pm.total_possible_days end) as last_year_possible_days,
    -- This year to date columns
    max(case when pm.period_type = 'this_year_to_date' then pm.utilization end) as this_year_to_date_utilization,
    max(case when pm.period_type = 'this_year_to_date' then pm.total_run_time_hours end) as this_year_to_date_run_time_hours,
    max(case when pm.period_type = 'this_year_to_date' then pm.total_possible_hours end) as this_year_to_date_possible_hours,
    max(case when pm.period_type = 'this_year_to_date' then pm.total_possible_days end) as this_year_to_date_possible_days,
    -- Last year to date columns
    max(case when pm.period_type = 'last_year_to_date' then pm.utilization end) as last_year_to_date_utilization,
    max(case when pm.period_type = 'last_year_to_date' then pm.total_run_time_hours end) as last_year_to_date_run_time_hours,
    max(case when pm.period_type = 'last_year_to_date' then pm.total_possible_hours end) as last_year_to_date_possible_hours,
    max(case when pm.period_type = 'last_year_to_date' then pm.total_possible_days end) as last_year_to_date_possible_days,
    -- Last year this week columns
    max(case when pm.period_type = 'last_year_this_week' then pm.utilization end) as last_year_this_week_utilization,
    max(case when pm.period_type = 'last_year_this_week' then pm.total_run_time_hours end) as last_year_this_week_run_time_hours,
    max(case when pm.period_type = 'last_year_this_week' then pm.total_possible_hours end) as last_year_this_week_possible_hours,
    max(case when pm.period_type = 'last_year_this_week' then pm.total_possible_days end) as last_year_this_week_possible_days,
    -- Last year this month columns
    max(case when pm.period_type = 'last_year_this_month' then pm.utilization end) as last_year_this_month_utilization,
    max(case when pm.period_type = 'last_year_this_month' then pm.total_run_time_hours end) as last_year_this_month_run_time_hours,
    max(case when pm.period_type = 'last_year_this_month' then pm.total_possible_hours end) as last_year_this_month_possible_hours,
    max(case when pm.period_type = 'last_year_this_month' then pm.total_possible_days end) as last_year_this_month_possible_days,
    -- Last year this month to date columns
    max(case when pm.period_type = 'last_year_this_month_to_date' then pm.utilization end) as last_year_this_month_to_date_utilization,
    max(case when pm.period_type = 'last_year_this_month_to_date' then pm.total_run_time_hours end) as last_year_this_month_to_date_run_time_hours,
    max(case when pm.period_type = 'last_year_this_month_to_date' then pm.total_possible_hours end) as last_year_this_month_to_date_possible_hours,
    max(case when pm.period_type = 'last_year_this_month_to_date' then pm.total_possible_days end) as last_year_this_month_to_date_possible_days,
    current_timestamp()::timestamp_ntz as data_refresh_timestamp
from period_metrics pm
group by rental_id, asset_id, shift_type_id

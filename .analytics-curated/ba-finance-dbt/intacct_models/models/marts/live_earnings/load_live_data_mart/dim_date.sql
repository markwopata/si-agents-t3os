with cte_my_date as (
    select dateadd(dd, seq4(), '2017-01-01 00:00:00') as my_date
    from table(generator(ROWCOUNT => 20000))
)

select
    to_date(my_date) as date, -- noqa: RF04
    year(my_date) as year,
    month(my_date) as month,
    to_char(my_date, 'MMMM') as month_name,
    to_char(my_date, 'MMMM')
    || ' '
    || cast(year(my_date) as varchar(30)) as period,
    to_char(dateadd(month, -1, my_date), 'MMMM')
    || ' '
    || cast(year(dateadd(month, -1, my_date)) as varchar(30)) as prior_period,
    to_char(dateadd(month, 1, my_date), 'MMMM')
    || ' '
    || cast(year(dateadd(month, 1, my_date)) as varchar(30)) as next_period,
    cast(year(my_date) as varchar(4))
    || right('0' || cast(month(my_date) as varchar(2)), 2) as year_month,
    day(my_date) as day,
    dayofweek(my_date) as day_of_week,
    weekofyear(my_date) as week_of_year,
    dayofyear(my_date) as day_of_year,
    coalesce(
        year(to_date(my_date)) = year(current_date),
        false
    ) as year_to_date,
    coalesce(
        year(to_date(my_date)) = year(current_date)
        and quarter(to_date(my_date)) = quarter(current_date),
        false
    ) as quarter_to_date,
    coalesce(
        year(to_date(my_date)) = year(current_date)
        and month(to_date(my_date)) = month(current_date), false
    ) as month_to_date,
    coalesce(
        to_date(my_date)
        >= dateadd(mm, -1, date_trunc('month', current_date))
        and to_date(my_date) < date_trunc('month', current_date)
        and day(to_date(my_date)) <= day(current_date),
        false
    ) as prior_month_to_date,
    coalesce(
        to_date(my_date)
        >= dateadd(mm, -1, date_trunc('month', current_date))
        and to_date(my_date) < date_trunc('month', current_date),
        false
    ) as prior_month,
    coalesce(
        to_date(my_date) >= date_trunc('month', current_date),
        false
    ) as current_month,
    coalesce(
        to_date(my_date)
        >= dateadd(quarter, -1, date_trunc(quarter, current_date))
        and to_date(my_date) < date_trunc(quarter, current_date),
        false
    ) as prior_quarter,
    false as has_data,
    false as has_data_time_entry,
    current_timestamp as record_created_timestamp,
    current_timestamp as record_modified_timestamp

from cte_my_date

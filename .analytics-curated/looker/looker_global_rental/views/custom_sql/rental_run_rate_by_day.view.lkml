view: rental_run_rate_by_day {
  derived_table: {
    sql:
     with rental_list as (
    select r.rental_id, rst.name as rental_status,
        convert_timezone( 'Pacific/Auckland', r.start_date) as rental_start,
        convert_timezone( 'Pacific/Auckland', r.end_date) as rental_end,
        r.price_per_day, r.price_per_week, r.price_per_month,
        ( DATEDIFF(DAY, r.START_DATE, r.end_date) - DATEDIFF(WEEK, r.START_DATE, r.end_date) * 2
            - (CASE WHEN DAYNAME(r.START_DATE) != 'Sun' THEN 1 ELSE 0 END)
            + (CASE WHEN DAYNAME(r.end_date) != 'Sat' THEN 1 ELSE 0 END)
            ) AS total_weekdays_on_rent,
        datediff(day, r.start_date::timestamp, r.end_date::timestamp) as total_all_days_on_rent
    from es_warehouse.public.orders o
        join es_warehouse.public.rentals r on o.order_id = r.order_id
        left join es_warehouse.public.markets m on o.market_id = m.market_id
        join es_warehouse.public.rental_statuses rst on rst.rental_status_id = r.rental_status_id
    where es_warehouse.public.overlaps(r.start_date, r.end_date, convert_timezone('Pacific/Auckland', 'UTC', dateadd(month, -12, current_date)), convert_timezone('Pacific/Auckland', 'UTC', dateadd(month, 1, current_date)))
        and r.rental_status_id in(5,6,7,9)
        and m.company_id = 6302
    )
    , est_rates as (
    select *,
        total_all_days_on_rent * price_per_day as est_daily_rate,
        case when (total_weekdays_on_rent/5) * price_per_week < price_per_week then price_per_week else (total_weekdays_on_rent/5) * price_per_week end as est_weekly_rate,
        case when (total_weekdays_on_rent/20) * price_per_month < price_per_month then price_per_month else (total_weekdays_on_rent/20) * price_per_month end as est_monthly_rate
    from rental_list
    )
    , cheapest_rate_calculation as (
    select *,
        least(est_daily_rate, est_weekly_rate, est_monthly_rate) as cheapest_rental,
        case when est_daily_rate = least(est_daily_rate, est_weekly_rate, est_monthly_rate) then 'Daily'
             when est_weekly_rate = least(est_daily_rate, est_weekly_rate, est_monthly_rate) then 'Weekly'
             when est_monthly_rate = least(est_daily_rate, est_weekly_rate, est_monthly_rate) then 'Monthly'
             else 'N/A' end as cheapest_rental_rate
    from est_rates er
    )
    , effective_daily_rate as (
    select *,
        case when cheapest_rental_rate = 'Daily' then price_per_day
             when cheapest_rental_rate = 'Weekly' then est_weekly_rate/case when total_weekdays_on_rent = 0 then null else total_weekdays_on_rent end
             when cheapest_rental_rate = 'Monthly' then est_monthly_rate/case when total_weekdays_on_rent = 0 then null else total_weekdays_on_rent end
             else 'N/A' end as effective_daily_rate
    from cheapest_rate_calculation crc
    )
    ,rental_day_list as (
    select series::date as rental_day
    from table(es_warehouse.public.generate_series(
                              dateadd(month, -12, current_date)::timestamp_tz,
                              dateadd(month, 1, current_date)::timestamp_tz,
                              'day')
                              )
    )
    , rental_effective_daily_rates_by_day as (
    select rdl.rental_day::date as rental_day,
        edr.rental_id,
        edr.rental_start,
        edr.rental_end,
        edr.cheapest_rental_rate,
        edr.effective_daily_rate
    from effective_daily_rate edr
        JOIN rental_day_list rdl
             ON rdl.rental_day BETWEEN edr.rental_start::date
             AND coalesce(dateadd(day, 1, edr.rental_end::date), '2099-12-31')
    )
  --  , omit_weekend_rates as (
    select rental_day,
        date_trunc('week', rental_day) as rental_week,
        date_trunc('month', rental_day) as rental_month,
        rental_id,
        rental_start,
        rental_end,
        cheapest_rental_rate, effective_daily_rate,
        case when cheapest_rental_rate = 'Weekly' and (dayname(rental_day) = 'Sat' or dayname(rental_day) = 'Sun') then 0
             when cheapest_rental_rate = 'Monthly' and (dayname(rental_day) = 'Sat' or dayname(rental_day) = 'Sun') then 0
             when cheapest_rental_rate = 'Daily' and (dayname(rental_day) = 'Sat' or dayname(rental_day) = 'Sun') then effective_daily_rate
             else effective_daily_rate
                end as calc_effective_daily_rate
    from rental_effective_daily_rates_by_day d
    order by rental_id, rental_start, rental_end
    ;;
  }


  dimension: rental_day {
    primary_key: yes
    type: date
    sql: ${TABLE}."RENTAL_DAY" ;;
  }

  dimension: rental_week {
    type: date
    sql: ${TABLE}."RENTAL_WEEK" ;;
  }

  dimension: rental_month {
    type: date
    sql: ${TABLE}."RENTAL_MONTH" ;;
  }

  dimension: rental_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: rental_start {
    type:date_time
    sql: ${TABLE}."RENTAL_START" ;;
  }

  dimension: rental_end {
    type: date_time
    sql: ${TABLE}."RENTAL_END" ;;
  }

  dimension: cheapest_rental_rate {
    type: string
    sql: ${TABLE}."CHEAPEST_RENTAL_RATE" ;;
  }

  dimension: calc_effective_daily_rate {
    label: "Effective Day Rate"
    type: number
    value_format_name: usd
    sql: ${TABLE}."CALC_EFFECTIVE_DAILY_RATE" ;;
  }

  measure: daily_rental_revenue {
    type: sum
    value_format_name: usd_0
    sql: ${calc_effective_daily_rate};;
    drill_fields: [rental_details*]
  }

  set: rental_details {
    fields: [rental_id, rental_details.customer, rental_details.rental_status, asset_class_customer_branch.asset_class,
            rental_details.asset_id, asset_class_customer_branch.asset_owner, rental_details.jobsite,  rental_start, rental_end,
            cheapest_rental_rate, calc_effective_daily_rate]
  }

 }

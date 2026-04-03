view: effective_day_rate_by_rental_id {
    derived_table: {
      sql:
          with rental_list as (
          select r.rental_id, rst.name as rental_status,
              convert_timezone( '{{ _user_attributes['user_timezone'] }}', r.start_date) as rental_start,
              convert_timezone( '{{ _user_attributes['user_timezone'] }}', r.end_date) as rental_end,
              r.price_per_day, r.price_per_week, r.price_per_month,
              ( DATEDIFF(DAY, r.START_DATE, r.end_date) - DATEDIFF(WEEK, r.START_DATE, r.end_date) * 2
                  - (CASE WHEN DAYNAME(r.START_DATE) != 'Sun' THEN 1 ELSE 0 END)
                  + (CASE WHEN DAYNAME(r.end_date) != 'Sat' THEN 1 ELSE 0 END)
                  ) AS total_weekdays_on_rent,
              floor(datediff(day, r.start_date::timestamp, r.end_date::timestamp)) as total_all_days_on_rent
          from es_warehouse.public.orders o
              join es_warehouse.public.rentals r on o.order_id = r.order_id
              left join es_warehouse.public.markets m on o.market_id = m.market_id
              join es_warehouse.public.rental_statuses rst on rst.rental_status_id = r.rental_status_id
          where es_warehouse.public.overlaps(r.start_date, r.end_date,
                                  convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}', dateadd(month, -2, current_date)),
                                  convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}', dateadd(month, 1, current_date)))
              and r.rental_status_id in(1,2,3,4,5,6,7,9)
              and m.company_id = {{ _user_attributes['company_id'] }}
          )
          , est_rates as (
          select *,
              total_weekdays_on_rent * price_per_day as est_daily_rate,
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
    --      , effective_daily_rate as (
          select *,
              case when cheapest_rental_rate = 'Daily' then price_per_day
                   when cheapest_rental_rate = 'Weekly' then est_weekly_rate/total_weekdays_on_rent
                   when cheapest_rental_rate = 'Monthly' then est_monthly_rate/total_weekdays_on_rent
                   else 'N/A' end as effective_daily_rate
          from cheapest_rate_calculation crc
          ;;
    }

    dimension: rental_id {
      primary_key: yes
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

    dimension: effective_daily_rate {
      label: "Effective Day Rate"
      type: number
      value_format_name: usd
      sql: ${TABLE}."EFFECTIVE_DAILY_RATE" ;;
    }
    }
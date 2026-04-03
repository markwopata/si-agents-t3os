view: effective_day_rate_by_asset_id {
  derived_table: {
    sql:
            with asset_rental_list as (
            select coalesce(ea.asset_id, r.asset_id) as asset_id,
                r.rental_id,
                convert_timezone( '{{ _user_attributes['user_timezone'] }}', coalesce(ea.start_date, r.start_date)) as asset_start,
                convert_timezone( '{{ _user_attributes['user_timezone'] }}', coalesce(ea.end_date, r.end_date)) as asset_end,
                floor(datediff(day, coalesce(ea.start_date, r.start_date), coalesce(ea.end_date, r.end_date))) as total_all_days_on_rent,
                r.price_per_day, r.price_per_week, r.price_per_month,
                 ( DATEDIFF(DAY, r.START_DATE, r.end_date) - DATEDIFF(WEEK, r.START_DATE, r.end_date) * 2
                  - (CASE WHEN DAYNAME(r.START_DATE) != 'Sun' THEN 1 ELSE 0 END)
                  + (CASE WHEN DAYNAME(r.end_date) != 'Sat' THEN 1 ELSE 0 END)
                  ) AS total_weekdays_on_rent
            from es_warehouse.public.rentals r
                join es_warehouse.public.equipment_assignments ea on ea.rental_id = r.rental_id
                join es_warehouse.public.orders o on r.order_id = o.order_id
                join es_warehouse.public.markets m on o.market_id = m.market_id
            where es_warehouse.public.overlaps(coalesce(ea.start_date, r.start_date), coalesce(ea.end_date, r.end_date),
                                                        convert_timezone('UTC', '{{ _user_attributes['user_timezone'] }}', dateadd(days, -179,  current_timestamp))::date,
                                                        convert_timezone('UTC',  '{{ _user_attributes['user_timezone'] }}', current_timestamp)::date + interval '59 mins' + interval '59 seconds')
                and r.rental_status_id in(1,2,3,4,5,6,7,9)
                and m.company_id = {{ _user_attributes['company_id'] }}
            --    and r.rental_id = 473478
            )
            , est_rates as (
            select *,
                total_weekdays_on_rent * price_per_day as est_daily_rate,
                case when (total_weekdays_on_rent/5) * price_per_week < price_per_week then price_per_week else (total_weekdays_on_rent/5) * price_per_week end as est_weekly_rate,
                case when (total_weekdays_on_rent/20) * price_per_month < price_per_month then price_per_month else (total_weekdays_on_rent/20) * price_per_month end as est_monthly_rate
            from asset_rental_list
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
            --, effective_daily_rate as (
            select asset_id, rental_id, asset_start, asset_end,
                total_all_days_on_rent,
                case when cheapest_rental_rate = 'Daily' then price_per_day
                     when cheapest_rental_rate = 'Weekly' then est_weekly_rate/total_weekdays_on_rent
                     when cheapest_rental_rate = 'Monthly' then est_monthly_rate/total_weekdays_on_rent
                     else 'N/A' end as effective_daily_rate
            from cheapest_rate_calculation crc
          ;;
  }

  dimension: compound_primary_key {
    primary_key: yes
    type: string
    sql: concat(${asset_id},${rental_id}) ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: rental_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: asset_start {
    type:date_time
    sql: ${TABLE}."ASSET_START" ;;
  }

  dimension: asset_end {
    type: date_time
    sql: ${TABLE}."ASSET_END" ;;
  }

  dimension: total_all_days_on_rent {
    label: "Total Days On Rent"
    type: number
    sql: ${TABLE}."TOTAL_ALL_DAYS_ON_RENT" ;;
  }

  dimension: effective_daily_rate {
    label: "Effective Day Rate"
    type: number
    value_format_name: usd
    sql: ${TABLE}."EFFECTIVE_DAILY_RATE" ;;
  }
}
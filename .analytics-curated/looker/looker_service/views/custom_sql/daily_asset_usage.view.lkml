view: daily_asset_usage {
  derived_table: {
    sql: with generated_dates as (
      select dateadd(day,'-' || row_number() over (order by null),dateadd(day, '+1', current_date())) as the_date
      from table (generator(rowcount => 400))
      )

      ,asset_dates as (
      select
            *,
            iff(date_part(dayofweek,the_date)=0,the_date,null) as thing,
            lag(thing) ignore nulls over (partition by asset_id order by the_date) as start_of_week
      from es_warehouse.public.assets a
      join generated_dates gd
      )

      ,hours as (
      select
            date(dateadd(hour,-6,report_range:end_range)) as the_date, --Setting data to be in CST
            asset_id,
            sum(on_time) as hours_on,
            sum(idle_time) as hours_idle,
      from es_warehouse.public.hourly_asset_usage hau
      group by the_date, asset_id
      )

      select
            a.the_date,
            a.start_of_week,
            dayname(a.the_date) as day_of_week,
            a.asset_id,
            coalesce(hau.hours_on,0) / 3600 as on_hours,
            coalesce(hau.hours_idle,0) / 3600 as idle_hours,
            (on_hours - idle_hours) as run_hours,
      from asset_dates a
      left join hours hau
          on a.asset_id = hau.asset_id
         and a.the_date = date(hau.the_date) ;;
  }

  dimension: asset_id_date {
    type: number
    primary_key: yes
    sql: concat(${asset_id},${date_date}) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format: "0"
  }

  dimension_group: date {
    type: time
    timeframes: [raw,date,week_of_year,day_of_week,day_of_week_index,month,quarter,year]
    sql: ${TABLE}."THE_DATE" ;;
  }

  dimension: last_30_flag {
    type: yesno
    sql: iff(${date_date} >= dateadd(day,-30,current_date),true,false) ;;
  }

  dimension: hours_on {
    type: number
    sql: ${TABLE}."ON_HOURS" ;;
  }

  dimension: hours_idle {
    type: number
    sql: ${TABLE}."IDLE_HOURS" ;;
  }

  dimension: hours_utilized {
    type: number
    sql: ${hours_on} - ${hours_idle} ;;
  }

  dimension: utilization {
    type: number
    sql: ${hours_utilized} / 8 ;;
  }

  measure: avg_daily_hours {
    type: average
    sql: ${hours_utilized} ;;
    drill_fields: [market_region_xwalk.market_name,
                  assets.asset_class,
                  avg_daily_hours_drill]
  }

  measure: avg_daily_hours_drill {
    type: average
    sql: ${hours_utilized} ;;
    drill_fields: [transportation_assets.asset_id,
                  assets.asset_class,
                  assets.make,
                  assets.model,
                  market_region_xwalk.market_name,
                  avg_daily_hours_drill_asset]
  }

  measure: avg_daily_hours_drill_asset {
    type: average
    sql: ${hours_utilized} ;;
    drill_fields: [date_date,
                  transportation_assets.asset_id,
                  assets.asset_class,
                  assets.make,
                  assets.model,
                  market_region_xwalk.market_name,
                  hours_utilized]
  }

  measure: sum_daily_hours {
    type: sum
    sql: ${hours_utilized} ;;
  }

  measure: avg_utilization_last_30_days {
    type: average
    sql: ${utilization} ;;
    filters: [last_30_flag: "yes", date_day_of_week_index: "0,1,2,3,4"]
  }
}

view: asset_utilization_last_30days {
  derived_table: {
    sql:
        with get_weekday_count as (
            select seq4() as day_num,
                   dateadd(day,'-' || day_num, current_date()) as generated_date,
                   dayname(generated_date),
                   case
                       when dayofweek(generated_date) = 0 or dayofweek(generated_date) =  6 then 1 else 0 end as weekend_flag,
                   count(generated_date) as num_days
            from table(generator(rowcount => 31))
            where weekend_flag = 0 and generated_date <> current_date
        )
        select asset_id,
               gwc.num_days,
               sum(run_hours) as total_run_hours,
               total_run_hours / nullifzero(gwc.num_days * 8) as utilization_rate
        from ${daily_asset_usage.SQL_TABLE_NAME}
        cross join get_weekday_count as gwc
        where the_date between dateadd(day,-30,current_date) and dateadd(day,-1,current_date) and
              dayofweek(the_date) in (1,2,3,4,5) --in snowflake, Monday is 1 but in Looker, Monday is 0
        group by 1,2;;
  }

  dimension: pkey {
    # type: string
    primary_key: yes
    hidden: yes
    sql: ${asset_id};;
  }
  dimension: asset_id {
    sql: ${TABLE}."ASSET_ID" ;;
    drill_fields: [
                   asset_id,
                   daily_asset_usage.the_date,
                   daily_asset_usage.hours_on,
                   daily_asset_usage.hours_idle,
                   daily_asset_usage.hours_utilized
                  ]
  }
  dimension: num_days {
    # hidden: yes
    type: number
    sql: ${TABLE}."NUM_DAYS" ;;
  }
  dimension: total_run_hours {
    type: number
    sql: ${TABLE}."TOTAL_RUN_HOURS" ;;
  }
  dimension: utilization_rate {
    type: number
    value_format_name: percent_1
    sql: ${TABLE}."UTILIZATION_RATE";;
  }
}

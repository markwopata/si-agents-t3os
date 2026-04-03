view: booked_rental_rate {
  derived_table: {
    sql: with date_series as (
      select
          series::date as day,
          dayname(series::date) as day_name
      from
          table (generate_series(
          dateadd(month, -12, current_date)::timestamp_tz,
          dateadd(month, 1, current_date)::timestamp_tz,
          'day')
          )
      )
      select
          ds.day,
          sum(effective_daily_rate) as effective_daily_rate
      from
          ES_WAREHOUSE_STAGE.PUBLIC.EFFECTIVE_DAILY_RATE edr
          JOIN date_series ds on ds.day BETWEEN edr.asset_start and edr.asset_end
      where
          edr.company_id = 6302
      group by
          ds.day
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: day {
    type: time
    sql: ${TABLE}."DAY" ;;
  }

  dimension: effective_daily_rate {
    type: number
    sql: ${TABLE}."EFFECTIVE_DAILY_RATE" ;;
  }

  dimension: day_formatted {
    group_label: "HTML Formatted"
    label: "Date"
    type: date
    sql: ${day_raw} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: month_formatted {
    group_label: "HTML Formatted"
    label: "Month"
    type: date
    sql: ${day_month} ;;
    html: {{ rendered_value | append: "-01" | date: "%b %Y" }};;
  }

  measure: total_effective_daily_rate {
    type: sum
    sql: ${effective_daily_rate} ;;
    value_format_name: usd_0
  }

  set: detail {
    fields: [day_raw, effective_daily_rate]
  }
}

view: asset_end_hours {
  derived_table: {
    sql: select h.asset_id, date_start, date_end, hours
      from scd.scd_asset_hours h
      where h.date_start <= convert_timezone('America/Chicago', 'UTC', dateadd(day, 1, COALESCE({% parameter end_date %}::timestamp,current_date())))
          and coalesce(h.date_end, (current_timestamp + interval '2 day')) >= convert_timezone('America/Chicago', 'UTC', dateadd(day, 1, COALESCE({% parameter end_date %}::timestamp,current_date() - interval '3 days')))
      QUALIFY row_number() over (PARTITION BY h.asset_id order by date_start::timestamp desc) = 1
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension_group: date_start {
    type: time
    sql: ${TABLE}."DATE_START" ;;
  }

  dimension_group: date_end {
    type: time
    sql: ${TABLE}."DATE_END" ;;
  }

  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
  }

  measure: total_end_hours {
    type: sum
    sql: ${hours} ;;
  }

  measure: overall_hours {
    type: number
    sql: ${total_end_hours} - ${asset_start_hours.total_start_hours} ;;
  }

  parameter: start_date {
    type: date
    # default_value: "2020-10-08"
  }

  parameter: end_date {
    type: date
    # default_value: "2020-10-14"
  }

  set: detail {
    fields: [asset_id, date_start_time, date_end_time, hours]
  }
}

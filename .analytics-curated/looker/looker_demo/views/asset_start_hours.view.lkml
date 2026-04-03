view: asset_start_hours {
  derived_table: {
    sql: select distinct h.asset_id, date_start, hours
        from scd.scd_asset_hours h
      where h.date_start <= convert_timezone('America/Chicago', 'UTC', dateadd(day, 1, COALESCE({% parameter end_date %}::timestamp,current_date())))
        and coalesce(h.date_end, current_timestamp) >= convert_timezone('America/Chicago', 'UTC', COALESCE({% parameter start_date %}::timestamp,current_date() - interval '3 days'))
      QUALIFY row_number() over (PARTITION BY h.asset_id order by date_start::timestamp) = 1
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

  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
  }

  measure: total_start_hours {
    type: sum
    sql: ${hours} ;;
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
    fields: [asset_id, date_start_time, hours]
  }
}

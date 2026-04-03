view: scd_asset_hours {
  sql_table_name: "SCD"."SCD_ASSET_HOURS"
    ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_scd_hours_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_SCD_HOURS_ID" ;;
  }

  dimension_group: date_end {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_END" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_start {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_START" AS TIMESTAMP_NTZ) ;;
  }

  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
  }

  filter: date_filter {
    description: "Use this date filter in combination with the timeframes dimension for dynamic date filtering"
    type: date
  }

  dimension_group: filter_start_date {
    type: time
    timeframes: [raw]
    sql: CASE WHEN {% date_start date_filter %} IS NULL THEN '1970-01-01' ELSE NULLIF({% date_start date_filter %}, 0)::timestamp END;;
  }

  dimension_group: filter_end_date {
    type: time
    timeframes: [raw]
    sql: CASE WHEN {% date_end date_filter %} IS NULL THEN CURRENT_DATE ELSE NULLIF({% date_end date_filter %}, 0)::timestamp END;;
  }

  dimension: interval {
    type: number
    sql: DATEDIFF(seconds, ${filter_start_date_raw}, ${filter_end_date_raw});;
  }

  dimension: previous_start_date {
    type: date
    sql: DATEADD(seconds, -${interval}, ${filter_start_date_raw}) ;;
  }

  dimension: timeframes {
    # description: "Use this field in combination with the date filter field for dynamic date filtering”
    suggestions: ["period","previous period"]
  type: string
  case:  {
    when:  {
      sql: ${date_start_raw} BETWEEN ${filter_start_date_raw} AND  ${filter_end_date_raw};;
      label: "Period"
    }
    when: {
      sql: ${date_start_raw} BETWEEN ${previous_start_date} AND ${filter_start_date_raw} ;;
      label: "Previous Period"
    }
    else: "Not in time period"
  }
}

measure: hours_total {
  type: sum
  sql: ${hours} ;;
}

  measure: count {
    type: count
    drill_fields: []
  }
}

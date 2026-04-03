view: out_of_lock_7_days_rolling {
  sql_table_name: "PUBLIC"."OUT_OF_LOCK_7_DAYS_ROLLING"
    ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
    value_format_name: id
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id
  }

  dimension: hours_out_of_lock {
    type: number
    sql: ${TABLE}."HOURS_OUT_OF_LOCK" ;;
  }

  dimension: out_of_lock_reason {
    type: string
    sql: ${TABLE}."OUT_OF_LOCK_REASON" ;;
  }

  dimension_group: out_of_lock_timestamp {
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
    sql: CAST(${TABLE}."OUT_OF_LOCK_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: over_72_hours_flag {
    type: yesno
    sql: ${TABLE}."OVER_72_HOURS_FLAG" ;;
  }

  dimension_group: snapshot {
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
    sql: CAST(${TABLE}."SNAPSHOT_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: unplugged_flag {
    type: yesno
    sql: ${TABLE}."UNPLUGGED_FLAG" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}

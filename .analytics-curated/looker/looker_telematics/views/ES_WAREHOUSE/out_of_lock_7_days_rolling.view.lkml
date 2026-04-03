view: out_of_lock_7_days_rolling {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."OUT_OF_LOCK_7_DAYS_ROLLING"
    ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: hours_out_of_lock {
    type: number
    sql: ${TABLE}."HOURS_OUT_OF_LOCK" ;;
  }

  dimension: out_of_lock_reason {
    type: string
    sql: ${TABLE}."OUT_OF_LOCK_REASON" ;;
  }

  dimension: out_of_lock_timestamp {
    type: date_time
    sql: ${TABLE}."OUT_OF_LOCK_TIMESTAMP" ;;
  }

  dimension: out_of_lock_timestamp_date {
    type: date
    sql: ${TABLE}."OUT_OF_LOCK_TIMESTAMP" ;;
  }

  dimension: over_72_hours_flag {
    type: yesno
    sql: ${TABLE}."OVER_72_HOURS_FLAG" ;;
  }

  dimension: snapshot {
    type: date_time
    sql: ${TABLE}."SNAPSHOT_DATE" ;;
  }

  dimension: snapshot_date {
    type: date
    sql: ${TABLE}."SNAPSHOT_DATE" ;;
  }

  dimension: unplugged_flag {
    type: yesno
    sql: ${TABLE}."UNPLUGGED_FLAG" ;;
  }

  measure: count {
    type: count
    drill_fields: [asset_id, hours_out_of_lock, out_of_lock_reason]
  }
}

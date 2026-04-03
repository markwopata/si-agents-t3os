view: asset_tracker_assignments {
  sql_table_name: "PUBLIC"."ASSET_TRACKER_ASSIGNMENTS"
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

  dimension: asset_tracker_id {
    type: number
    sql: ${TABLE}."ASSET_TRACKER_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: date_installed {
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
    sql: CAST(${TABLE}."DATE_INSTALLED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_uninstalled {
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
    sql: CAST(${TABLE}."DATE_UNINSTALLED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}

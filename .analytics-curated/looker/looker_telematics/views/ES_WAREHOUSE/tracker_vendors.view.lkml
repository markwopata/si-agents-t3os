view: tracker_vendors {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."TRACKER_VENDORS"
    ;;
  drill_fields: [tracker_vendor_id]

  dimension: tracker_vendor_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."TRACKER_VENDOR_ID" ;;
  }

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

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [tracker_vendor_id, name, tracker_types.count]
  }
}

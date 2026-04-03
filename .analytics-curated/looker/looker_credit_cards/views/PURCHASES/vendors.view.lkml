view: vendors {
  sql_table_name: "PURCHASES"."VENDORS"
    ;;
  drill_fields: [vendor_id]

  dimension: vendor_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
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

  dimension: entity {
    type: string
    sql: ${TABLE}."ENTITY" ;;
  }

  dimension: id {
    type: string
    sql: ${TABLE}."ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: record_num {
    type: number
    sql: ${TABLE}."RECORD_NUM" ;;
  }

  dimension: term_name {
    type: string
    sql: ${TABLE}."TERM_NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [vendor_id, term_name, name, purchases.count]
  }
}

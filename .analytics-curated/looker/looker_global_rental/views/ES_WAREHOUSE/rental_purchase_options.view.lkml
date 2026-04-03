view: rental_purchase_options {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."RENTAL_PURCHASE_OPTIONS"
    ;;
  drill_fields: [rental_purchase_option_id]

  dimension: rental_purchase_option_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."RENTAL_PURCHASE_OPTION_ID" ;;
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
    label: "RPO Option"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [rental_purchase_option_id, name]
  }
}

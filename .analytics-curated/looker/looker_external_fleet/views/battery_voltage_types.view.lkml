view: battery_voltage_types {
  sql_table_name: "PUBLIC"."BATTERY_VOLTAGE_TYPES"
    ;;
  drill_fields: [battery_voltage_type_id]

  dimension: battery_voltage_type_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."BATTERY_VOLTAGE_TYPE_ID" ;;
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

  dimension: is_internal {
    type: yesno
    sql: ${TABLE}."IS_INTERNAL" ;;
  }

  dimension: name {
    label: "Battery Voltage Type"
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: threshold {
    type: string
    sql: ${TABLE}."THRESHOLD" ;;
  }

  measure: count {
    type: count
    drill_fields: [assets.custom_name, name]
    html: {{rendered_value}} ({{count_percent._rendered_value}}) ;;
  }

  measure: count_percent {
    type: percent_of_total
    sql: ${count} ;;
  }
}

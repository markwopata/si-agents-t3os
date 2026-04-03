view: asset_status_key_values {
  sql_table_name: "PUBLIC"."ASSET_STATUS_KEY_VALUES"
    ;;
  drill_fields: [asset_status_key_value_id]

  dimension: asset_status_key_value_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_STATUS_KEY_VALUE_ID" ;;
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

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_status_value_type_id {
    type: number
    sql: ${TABLE}."ASSET_STATUS_VALUE_TYPE_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension_group: updated {
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
    sql: CAST(${TABLE}."UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: value {
    type: string
    sql: ${TABLE}."VALUE" ;;
  }

  dimension_group: value_timestamp {
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
    sql: CAST(${TABLE}."VALUE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  measure: count {
    type: count
    drill_fields: [asset_status_key_value_id, name, value]
  }
}

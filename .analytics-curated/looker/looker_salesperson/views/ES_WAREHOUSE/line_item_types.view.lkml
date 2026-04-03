view: line_item_types {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."LINE_ITEM_TYPES"
    ;;
  drill_fields: [line_item_type_id]

  dimension: line_item_type_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID";;
    value_format_name: id
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
    sql: ${TABLE}.CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: active {
    type: yesno
    sql: ${TABLE}."ACTIVE" ;;
  }

  dimension: fixed_amount {
    type: number
    sql: ${TABLE}."FIXED_AMOUNT" ;;
    value_format_name: usd_0
  }

  dimension: invoice_display_name {
    type: string
    sql: ${TABLE}."INVOICE_DISPLAY_NAME" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: stackable {
    type: yesno
    sql: ${TABLE}."STACKABLE" ;;
  }

  dimension: tax_code_id {
    type: number
    sql: ${TABLE}."TAX_CODE_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [line_item_type_id, invoice_display_name, name]
  }
}

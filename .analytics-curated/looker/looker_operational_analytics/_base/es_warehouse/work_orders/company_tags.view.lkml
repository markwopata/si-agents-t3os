view: company_tags {
  sql_table_name: "ES_WAREHOUSE"."WORK_ORDERS"."COMPANY_TAGS" ;;
  drill_fields: [company_tag_id]

  dimension: company_tag_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_TAG_ID" ;;
    value_format_name: id
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: color {
    type: string
    sql: ${TABLE}."COLOR" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id
  }
  dimension: deleted_by {
    type: number
    sql: ${TABLE}."DELETED_BY" ;;
  }
  dimension_group: deleted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DELETED_ON" AS TIMESTAMP_NTZ) ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [company_tag_id, name, work_order_company_tags.count]
  }
  measure: tags_on_work_order {
    type: list
    list_field: name
  }
}

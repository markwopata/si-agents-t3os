view: work_order_company_tags {
  sql_table_name: "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDER_COMPANY_TAGS" ;;
  drill_fields: [work_order_company_tag_id]

  dimension: work_order_company_tag_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."WORK_ORDER_COMPANY_TAG_ID" ;;
    value_format_name: id
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: company_tag_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."COMPANY_TAG_ID" ;;
    value_format_name: id
  }
  dimension_group: deleted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DELETED_ON" AS TIMESTAMP_NTZ) ;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }
  measure: count {
    type: count
    drill_fields: [work_order_company_tag_id, company_tags.company_tag_id, company_tags.name]
  }
}
